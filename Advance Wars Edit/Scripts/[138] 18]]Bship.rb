################################################################################
# Class Bship
#   Cost : 22000                Move : 5      Move Type : Water
#   Vision : 2                  Fuel : 70
#   Primary Weapon : Cannons                  Ammo : 6
#   Secondary Weapon : None
################################################################################
class Bship < Unit
  def initialize(*args)
    super(*args)
    @name = "battleship"
    @real_name = "Battleship"
    @unit_type = 18
    @cost = 26000
    @move = 5
    @move_type = 6
    @vision = 2
    @max_fuel = 70
    @fuel = 70
    @fuel_cost = 1
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Cannons"
    @weapon1_effect = [2, 2, 2, 2, 0, 0]
    @min_range = 2
    @max_range = 6
    @star_energy = 200
    @move_se = "ship"
    
    @stat_desc = ["Battleships have a devastating range that can do high damage.",
      "This is the unit\'s movement. It can only travel across the sea.",
      "The vision of this unit is somewhat weak.",
      "The unit burns 1 unit of fuel each day. It sinks when it drops to zero.",
      "Battleships can engage ground targets from afar with its cannons.",
      "This attack does high damage against infantry.",
      "This attack does high damage against vehicles.",
      "This attack does high damage against ships.",
      "This attack does high damage against surfaced subs.",
      "The unit can no longer fire when out of ammo.", "", "","", ""]
  end
  
  def description
    return "An expensive sea unit that can engage ground targets from afar."
  end
end
$UNITS.push(Bship)