class Shoal < Tile
  def initialize
    super
    @name = 'shoal'
    @id = TILE_SHOAL
  end
  
  def move_cost_chart(move_type)
    return case move_type         
    when MOVE_FOOT then return    [1,2]
    when MOVE_MECH then return    [1,2]
    when MOVE_TIRE then return    [2,3,3]
    when MOVE_TREAD then return   [1,2,2]
    when MOVE_AIR then return     [1,2]
    when MOVE_TRANS then return   [1,2]
    when MOVE_SEA then return     [0]
    when MOVE_TIRE_B then return  [1,2,2]
    end
  end
end