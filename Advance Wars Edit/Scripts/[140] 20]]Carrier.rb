################################################################################
# Class Cruiser
#   Cost : 15000                Move : 6      Move Type : Water
#   Vision : 4                  Fuel : 99
#   Primary Weapon : Rockets                  Ammo : 6
#   Secondary Weapon : Machine Gun
################################################################################
class Carrier < Unit
  def initialize(*args)
    super(*args)
    @name = "carrier"
    @real_name = "Carrier"
    @unit_type = 20
    @cost = 28000
    @move = 5
    @move_type = 6
    @vision = 4
    @max_fuel = 70
    @fuel = 70
    @fuel_cost = 1
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Missiles"
    @weapon1_effect = [0, 0, 0, 0, 2, 2]
    @min_range = 3
    @max_range = 8
    @star_energy = 200
    @can_carry = true
    @move_se = "ship"
    
    @stat_desc = ["Aircraft carriers can hold and repair 2 air units at a time.",
      "This is the unit\'s movement. It can only travel across the sea.",
      "The vision of this unit is somewhat distant.",
      "The unit burns 1 unit of fuel each day. It sinks when it drops to zero.",
      "Carriers have anti-air missiles that can be fired large distances.",
      "This attack can destroy copters in one shot.",
      "This attack can destroy planes in one shot.", "", "",
      "The unit can no longer fire when out of ammo.", "", "","", ""]
  end
  
  def description
    return "A large ship that can carry and repair two air units."
  end
  
  def carry_capability(unit)
    return false if @holding_units.size == 2
    return true if unit.move_type == MOVE_AIR
    return false
  end
  
  def carry_effect
    bool = false
    @holding_units.each{|u|
      next unless (u.fuel < u.max_fuel or u.ammo < u.max_ammo or u.health < 100)
      u.supply 
      u.repair(2, true)
      bool = true
    }
    return bool
  end
  
  #-----------------------------------------------------------------------------
  # Checks if the unit is over a tile that it can drop units off.
  #-----------------------------------------------------------------------------
  def valid_drop_spot(x,y)
    return true
  end

end
$UNITS.push(Carrier)
  