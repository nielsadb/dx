
require 'set'
require 'values'
require './util.rb'

class Index
  Info = Value.new(:name, :depth, :size, :type, :date, :tags)
  Entry = Value.new(:info, :parent, :children)

  def initialize(root)
    @root = root
    @entries = {}
  end

  def touch(name:, size:nil, type:nil, date:nil, tags:nil)
    name = File.absolute_path(name.strip, @root)
    return if name == @root
    old_entry = @entries[name]
    @entries[name] = if old_entry then
      oldi = old_entry.info
      old_entry.with(info: oldi.with(
          size: size || oldi.size,
          type: type || oldi.type,
          date: date || oldi.date,
          tags: merge_sets(oldi.tags, tags)))
    else
      parent = File.dirname(name)
      raise "parent not yet added of #{name}" unless @entries[parent] || parent == @root
      new_entry = Entry.with(
        info: Info.with(
          name: name,
          depth: if parent == @root then 1 else @entries[parent].info.depth + 1 end,
          size: size,
          type: type,
          date: date,
          tags: (tags || Set.new())),
        children: [],
        parent: parent)
      # side-effect: nest the new value in the existing index
      if new_entry.info.depth > 1 then
        @entries[new_entry.parent].children.append(name)
      end
      new_entry
    end
  end
  
  def find(from:nil, name:nil, mindepth:1, maxdepth:0, tags:nil, children:nil, mode: :default)
    names, depth_offset = if from then
      [@entries[from].children, @entries[from].info.depth]
    else
      [@entries.select {|_, x| x.info.depth == 1}.keys, 0]
    end
    recur = ->(n, y) {
      raise "n must be a string" unless n.is_a? String
      entry = @entries[n]
      raise "entry with name #{n} does not exist" unless entry
      depth = entry.info.depth - depth_offset
      return unless (depth <= maxdepth || maxdepth == 0) 
      if mindepth <= depth then
        match = case name
        when nil
          true
        when Array
          name.any? {|re| re.match(n)}
        when Regexp
          name.match(n)
        else
          raise "wrong argument for 'name'"
        end &&
        case tags
        when nil
          true
        when Set
          tags.subset?(entry.info.tags)
        else
          raise "wrong argument for 'tags'"
        end &&
        case children
        when nil
          true
        when Integer
          entry.children.size() == children
        else
          raise "wrong argument for 'children'"
        end
        trigger = case mode
          when :always
            true
          when :default
            match
          when :invert
            !match
          else
            raise 'illegal mode'
          end
        if trigger then
          # This must not mutate the index!
          y.yield(entry.info, match)
        end
      end
      entry.children.each do |n|
        recur.call(n, y)
      end
    }
    Enumerator.new do |y|
      names.each do |n|
        recur.call(n, y)
      end
    end
  end

  def valid?()
    @entries.all? do |name, entry|
      valid = name.is_a?(String) &&
        entry.is_a?(Entry) &&
        entry.info.size.is_a?(Numeric) &&
        entry.info.type.is_a?(Symbol)
      if not valid then
        pp [name, entry]
      end
      valid
    end
  end

  def rename_leaf(name, to:)
    raise "not implemented"
  end

  def move_up(name)
    entry = @entries[name]
    raise "cannot move to unknown location" unless entry.parent
    raise "cannot move a directory up, only files" unless entry.type == :file
    opa = @entries[entry.parent].parent
    new_name = File.join(opa, File.basename(name))
    entry.name = new_name
    if opa != @root then
      @entries[opa].children.append(new_name)
    end
  end

  def rmtag(name, tag:)
    old = @entries[name]
    @entries[name] = old.with(
      info: old.info.with(
        old.tags.clone.delete(tag).freeze))
  end

  def rm(name)
    entry = @entries[name]
    @entries.delete(name)
    if @entries[entry.parent] then
      @entries[entry.parent].children.delete(name)
    end
    entry.children.each {|child| rm(child)}
  end

  def dump(out: $>)
    find.each do |info|
      out.puts "#{'|   '*(info.depth-1)}#{info.name}    @[#{info.tags.to_a.sort.join(' ')}] (#{info.date})"
    end
  end
end
