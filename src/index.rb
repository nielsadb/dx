
require 'set'

class Index
  def initialize(root)
    @root = root
    @entries = {}
    @root_entries = Set.new()
  end

  Entry = Struct.new(:name, :size, :type, :date, :tags, :parent, :children, keyword_init: true)

  def touch(name:, size:nil, type:nil, date:nil, tags:nil)
    name = File.absolute_path(name.strip, @root)
    if name == @root then
      raise ArgumentError.new("must not add the root itself")
    end
    entry = @entries[name]
    if not entry then
      parent = File.dirname(name)
      entry = Entry.new(
        name:     name,
        size:     size,
        type:     type,
        date:     date,
        tags:     tags || Set.new(),
        children: [],
        parent:   parent)
        if parent == @root then
          @root_entries.add(name)
        else
          raise ArgumentError.new("must add parent before child") unless @entries[parent]
          @entries[parent].children.append(name)
        end  
        @entries[name] = entry
    end
    entry.size = size || entry.size
    entry.type = type || entry.type
    entry.date = date || entry.date
    if tags then
      entry.tags.merge(tags)
    end
  end

  def find(from:nil, name:nil, mindepth:1, maxdepth:0, tags:nil, invert:false)
    visit = ->(n, depth) {
      return unless (mindepth <= depth) && (depth <= maxdepth || maxdepth == 0)
      entry = @entries[n]
      match = (name == nil || name.match(n)) && (tags == nil || tags.subset?(entry.tags))
      if (match && !invert) or (!match && invert) then
        yield n, depth, entry.tags, entry.date
      end
      entry.children.each do |child|
        visit.call(child, depth+1)
      end
    }
    from = if from then
      @entries[from].children
    else
      @root_entries
    end
    from.each do |child|
      visit.call(child, 1)
    end
  end

  def rename(name, to:)
    rm(name: name)
    touch(name: to,
      size: entry.size,
      type: entry.type,
      date: entry.date,
      tags: entry.tags)
  end

  def moveup(name)
    entry = @entries[name]
    raise "cannot move to unknown location" unless entry.parent
    raise "cannot move a directory up, only files" unless entry.type == :file
    opa = @entries[entry.parent].parent
    new_name = File.join(opa, File.basename(name))
    entry.name = new_name
    if opa == @oroot then
      @root_entries.add(new_name)
    else
      @entries[opa].children.append(new_name)
    end
  end

  def rmtag(name, tag:)
    @entries[name].tags.delete(tag)
  end

  def rm(name, recursive:false)
    entry = @entries[name]
    @entries.delete(name)
    @root_entries.delete(name)
    if @entries[entry.parent] then
      @entries[entry.parent].children.delete(name)
    end
    if recursive then
      find(from:name) do |n|
        @entries.delete(n)
      end
    end
  end

  def depth(name)
    depth = 0
    while name != @root
      name = @entries[name].parent
      depth = depth + 1
    end
    depth
  end

  def dump(out: $>)
    find do |name, depth, tags, date|
      out.puts "#{'|   '*(depth-1)}#{name}    @[#{tags.to_a.sort.join(' ')}] (#{date})"
    end
  end
end
