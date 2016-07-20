################################################################################
# Class APC
#   Cost : 5000                 Move : 6      Move Type : Tread
#   Vision : 1                  Fuel : 60
#   Primary Weapon : None                     Ammo : N/A
#   Secondary Weapon : None
################################################################################
class Apc < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "apc"
    @real_name = "APC"
    @unit_type = 3
    @cost = 5000
    @move = 6
    @move_type = 3
    @max_fuel = 70
    @fuel = 70
    @max_range = 0
    @weapon2 = ""
    @star_energy = 40
    @can_carry = true
    @can_supply = true
    @can_daily_supply = true
    @move_se = "wheels"
    
    @stat_desc = ["A transport unit that can carry infantry and resupply nearby units.",
      "This unit moves a far distance. The unit travels on treads.",
      "APC units cannot see far at all.",
      "The unit moves on fuel. It can no longer move if it drops to zero.",
      "This unit has no weapons and cannot attack.", "", "", "", "",
      "", "", "","", ""]
  end
  
  def description
    return "A transport unit that can carry infantry and resupply nearby units."
  end

  def carry_capability(unit)
    # Only carries one unit
    return false if @holding_units.size == 1
    # Only carries foot soldiers
    return true if (unit.move_type == MOVE_FOOT or unit.move_type == MOVE_MECH)
    # Can't carry anything else
    return false
  end
  #-----------------------------------------------------------------------------
  # Checks if the unit is over a tile that it can drop units off.
  #-----------------------------------------------------------------------------
  def valid_drop_spot(x,y)
    # This unit is always on the ground, as are its cargo
    return true
  end

  
  
  
end
$UNITS.push(Apc)