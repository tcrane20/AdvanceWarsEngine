################################################################################
# Class Lander
#   Cost : 10000                Move : 6      Move Type : Trans
#   Vision : 1                  Fuel : 99
#   Primary Weapon : None                     Ammo : N/A
#   Secondary Weapon : None
################################################################################
class Lander < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "lander"
    @real_name = "Lander"
    @unit_type = 15
    @cost = 10000
    @move = 6
    @move_type = 5
    @fuel_cost = 1
    @max_range = 0
    @weapon2 = ""
    @star_energy = 75
    @can_carry = true
    @move_se = "ship"
    
    @stat_desc = ["Landers can quickly transport two land units across the sea.",
      "This is the unit\'s movement. Landers can move along beaches.",
      "The vision of this unit is poor.",
      "The unit burns 1 unit of fuel each day. It sinks when it drops to zero.",
      "Landers have no weapons and cannot attack.", "", "","", "",
      "", "", "","", ""]
  end
  
  def description
    return "A transport sea unit capable of holding two ground units."
  end
  
  def carry_capability(unit)
    return false if @holding_units.size == 2
    return true if [MOVE_FOOT, MOVE_MECH, MOVE_TIRE, MOVE_TREAD, MOVE_TIRE_B].include?(unit.move_type)
    return false
  end
  #-----------------------------------------------------------------------------
  # Checks if the unit is over a tile that it can drop units off.
  #-----------------------------------------------------------------------------
  def valid_drop_spot(x,y)
    tile_id = $game_map.get_tile(x, y).id
    return [TILE_SHOAL, TILE_SEAPORT].include?(tile_id)
  end

end
$UNITS.push(Lander)