################################################################################
# Class Cruiser
#   Cost : 15000                Move : 6      Move Type : Water
#   Vision : 4                  Fuel : 99
#   Primary Weapon : Rockets                  Ammo : 6
#   Secondary Weapon : Machine Gun
################################################################################
class Destroyer < Unit
  def initialize(*args)
    super(*args)
    @name = "destroyer"
    @real_name = "Destroyer"
    @unit_type = 22
    @cost = 18000
    @move = 6
    @move_type = 6
    @vision = 2
    @fuel_cost = 1
    @max_ammo = 9
    @ammo = 9
    @weapon1 = "Cannons"
    @weapon2 = "Chain Gun"
    @weapon1_effect = [0, 2, 2, 1, 0, 0]
    @weapon2_effect = [2, 1, 0, 0, 0, 0]
    @star_energy = 135
    @move_se = "ship"
    
    @stat_desc = ["Destroyers are powerful units that can damage land and sea units.",
      "Destroyers move a far distance. They travel through the sea.",
      "The vision of this unit is somewhat weak.",
      "The unit burns 1 unit of fuel each day. It sinks when it drops to zero.",
      "Destroyers have massive cannons as its primary weapon.",
      "This unit does more damage than a medium tank to vehicles.",
      "Destroyers do heavy damage to other ships.",
      "Destroyers do decent damage to surfaced subs.", "",
      "Destroyers are armed with a somewhat effective chain gun.",
      "This unit does high damage to infantry units.",
      "Don't expect much damage against vehicles.", "", ""]
  end
  
  def description
    return "A direct combat sea unit that can damage land units."
  end
  
end
$UNITS.push(Destroyer)