#============================================================================
# Tiles that can be attacked or are essentially impassable walls
#============================================================================
class Structure < Tile
  attr_accessor :hp, :x, :y, :damage_chart
  
  def initialize(x,y)
    super
    @x, @y = x, y
    @hp = -1
    @size = [1,1]
    @weakspot = nil
    @damage_chart = [
      # Primary Weapon
      #   0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25
      #  INF MEC RCN APC ART TNK AAR MIS RKT MDT NEO TCP BCP FTR BMR LND CRU SUB BSP MEG CAR STH DST ZEP BKE ATK 
        [ -1, 20, -1, -1, 35, 20,  5, -1, 55, 55, 75, -1, 25, -1, 95, -1, -1, -1, 75,105, -1, 45, 65, 20, -1, 45],
      # Secondary Weapon
      #   0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25
      #  INF MEC RCN APC ART TNK AAR MIS RKT MDT NEO TCP BCP FTR BMR LND CRU SUB BSP MEG CAR STH DST ZEP BKE ATK
        [  1,  1,  1, -1, -1,  1, -1, -1, -1,  1,  2, -1,  1, -1, -1, -1, -1, -1, -1,  3, -1, -1,  2, -1,  1, -1]
      ]
  end
  
  def injure(amount, *args)
    @hp -= amount
    if @hp <= 0
      @hp = 0
    end
  end
  
  def move_cost_chart(move_type)
    return 0
  end
  
  def attack_range
    return false
  end
  
end