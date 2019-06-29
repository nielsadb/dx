
class Cmd
  def initialize(tag:)
    @tag = tag
  end
end

class Move < Cmd
  def initialize(from:, to:)
    super(:move)
  end
end


class Collector
  def initialize()
  end

  ValidTypes = [:dir, :file]

  def touch(name:, size:nil, type:nil, date:nil, tag:nil, parent:nil)
    if date and not date.is_a?(Time) then
      raise ArgumentError.new("type of date must be Time, got a #{date.class}")
    end
    if type and ValidTypes.include?(type) then
      raise ArgumentError.new("type #{type} not in #{@valid_types}")
    end
  end

  def nest(is_root)
    return Index.new 
  end
end

class Index
end

class InMemoryIndex < Index
  def initialize()
    @entries = []
  end

  def find(name://, tags:[], mindepth:1, maxdepth:1, invert:false)
  end

  def mv(from, to:)
    target = if to == :up then
      to # FIXME
    else
      to 
    end
  end

  def touch(name, tags:nil, date:nil)
  end

  def rm(name, tag:nil)
  end

  def dump(stream)
    # Print an actually usable format (not so super verbose).
  end
end

