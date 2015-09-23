class Pipe < Tile
  def initialize
    super
    @name = 'pipe'
    @id = TILE_PIPE
  end
  
  def move_cost(unit)
    # Normal movechart
    case unit.move_type
    when MOVE_FOOT then return 0
    when MOVE_MECH then return 0
    when MOVE_TIRE then return 0
    when MOVE_TREAD then return 0
    when MOVE_AIR then return 0
    when MOVE_TRANS then return 0
    when MOVE_SEA then return 0
    when MOVE_TIRE_B then return 0
    end
  end
end
