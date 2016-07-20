class Reef < Tile
  def initialize
    super
    @name = 'reef'
    @id = TILE_REEF
    @defense = 1
    @fow_cover = true
  end
  
  def move_cost_chart(move_type)
    return case move_type         
    when MOVE_FOOT then return    [0]
    when MOVE_MECH then return    [0]
    when MOVE_TIRE then return    [0]
    when MOVE_TREAD then return   [0]
    when MOVE_AIR then return     [1,2]
    when MOVE_TRANS then return   [2,3]
    when MOVE_SEA then return     [2,3]
    when MOVE_TIRE_B then return  [0]
    end
  end
end