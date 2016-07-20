################################################################################
# Class Tcop
#   Cost : 5000                 Move : 6      Move Type : Air
#   Vision : 2                  Fuel : 99
#   Primary Weapon : None                     Ammo : N/A
#   Secondary Weapon : None
################################################################################
class Tcop < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "tcopter"
    @real_name = "T. Copter"
    @unit_type = 11
    @cost = 5000
    @move = 6
    @move_type = 4
    @vision = 2
    @fuel_cost = 3
    @max_range = 0
    @weapon2 = ""
    @star_energy = 40
    @can_carry = true
    @move_se = "copter"
    
    @stat_desc = ["Transport copters can carry one infantry unit over difficult terrain.",
      "This unit moves a far distance. It is unaffected by terrain.",
      "This unit cannot see far at all.",
      "The unit burns 3 units of fuel each day. It crashes when it drops to zero.",
      "This unit has no weapons and cannot attack.", "", "","", "",
      "", "", "","", ""]
  end
  
  def description
    return "A mobile copter that can transport infantry units."
  end
  
  def carry_capability(unit)
    return false if @holding_units.size == 1
    return true if (unit.move_type == MOVE_FOOT or unit.move_type == MOVE_MECH)
    return false
  end
  #-----------------------------------------------------------------------------
  # Checks if the unit is over a tile that it can drop units off.
  #-----------------------------------------------------------------------------
  def valid_drop_spot(x,y)
    tile_id = $game_map.get_tile(x, y).id
    return false if [TILE_SEA, TILE_REEF].include?(tile_id)
    return true
  end

end
$UNITS.push(Tcop)