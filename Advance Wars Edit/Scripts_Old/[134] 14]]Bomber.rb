################################################################################
# Class Bomber
#   Cost : 22000                Move : 7      Move Type : Air
#   Vision : 2                  Fuel : 70
#   Primary Weapon : Bombs                    Ammo : 6
#   Secondary Weapon : None
################################################################################
class Bomber < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "bomber"
    @real_name = "Bomber"
    @unit_type = 14
    @cost = 22000
    @move = 7
    @move_type = 4
    @vision = 2
    @max_fuel = 80
    @fuel = 80
    @fuel_cost = 5
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Bombs"
    @weapon1_effect = [2, 2, 2, 2, 0, 0]
    @star_energy = 200
    @move_se = "b_plane"
    
    @stat_desc = ["Bombers are massive planes that drop salvos of bombs on targets below.",
      "Bombers have high movement. It is unaffected by terrain.",
      "The vision of this unit is somewhat weak.",
      "The unit burns 5 units of fuel each day. It crashes when it drops to zero.",
      "Bombers drop bombs onto targets below.",
      "Bombers wreak havoc on infantry units.",
      "The attack deals heavy damage to vehicles of all sizes.",
      "The attack deals great damage to ships.",
      "The attack deals great damage to surfaced subs.",
      "Bombers can no longer attack when it runs out of ammo.", "", "","", ""]
  end
  
  def description
    return "A bulky plane that drops bombs onto targets below."
  end
end
$UNITS.push(Bomber)