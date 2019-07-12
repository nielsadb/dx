
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


