class Pipe < Tile
  def initialize
    super
    @name = 'pipe'
    @id = TILE_PIPE
  end
  
  def move_cost_chart(move_type)
    return 0
  end
end
