
# Expected input on stream is as output by the following command:
#   find . -exec ls -ldT {} + -exec tag {} +
#
# The root directory may be included in the results, it will be ignored.

def parse_stream(stream, root)
  entries = {}
  stream.each do |line|
    ls = line.match /^(.)\S+\s+\d+\s+\S+\s+\S+\s+(\d+)\s+(\S+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+(\d+)\s+(.+)$/
    if ls then
      name = File.absolute_path(ls[9], root)
      raise "Duplicate entry for #{name}." unless not entries[name] or entries[name].kind_of?(Array)
      entries[name] = Entry.new(
        is_dir:   ls[1] == 'd',
        size:     ls[2].to_i,
        date:     Time.local(ls[8].to_i, ls[3], ls[4], ls[5].to_i, ls[6].to_i, ls[7].to_i),
        name:     name,
        tags:     (entries[name] or []),
        parent:   File.dirname(name),
        children: []
      )
    else
      tag = line.match /^([^\t]+)\t(\S+)$/
      if tag then
        name = File.absolute_path(tag[1].strip, root)
        tags = tag[2].split(',')
        if entries[name] then
          raise "Tags specified twice for #{name}" unless entries[name].kind_of?(Entry) and entries[name].tags.empty?
          entries[name].tags = tags
        else
          entries[name] = tags
        end
      end
    end
  end
  entries
end

def nest_entries(entries, root)
  root_entries = []
  entries.each do |name, entry|
    next if name == root
    if entry.parent == root then
      entry.parent = nil
      root_entries.append(name)
    else
      raise "Parent of #{name} not found" unless entries[entry.parent]
      entries[entry.parent].children.append(name)
    end
  end
  root_entries
end

def baseline(options)
  root = File.absolute_path(options.root)
  entries = parse_stream(options.input, root)
  root_entries = nest_entries(entries, root)
  State.new(
    roots:    root_entries,
    entries:  entries,
    commands: []
  )
end  
