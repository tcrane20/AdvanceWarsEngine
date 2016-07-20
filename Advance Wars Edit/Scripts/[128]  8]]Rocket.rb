################################################################################
# Class Rocket
#   Cost : 13000                Move : 5      Move Type : Tire
#   Vision : 1                  Fuel : 60
#   Primary Weapon : Rocket                   Ammo : 6
#   Secondary Weapon : None
################################################################################
class Rocket < Unit
  def initialize(*args)
    super(*args)
    @name = "rocket"
    @real_name = "Rockets"
    @unit_type = 8
    @cost = 15000
    @move = 5
    @move_type = 2
    @max_fuel = 60
    @fuel = 60
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Rocket"
    @weapon1_effect = [2, 2, 2, 2, 0, 0]
    @min_range = 3
    @max_range = 5
    @star_energy = 100
    @move_se = "wheels"
    
    @stat_desc = ["Rocket launchers are packed with deadly rockets to attack ground units from afar.",
      "The movement of this unit is severly reduced due to the wheels it travels on.",
      "Rockets cannot attack in Fog of War without help from other units.",
      "The unit moves on fuel. It can no longer move if it drops to zero.",
      "Rocket launchers fire rockets. It can attack land and sea units from far away.",
      "Rockets can wipe out waves of infantry in one attack.",
      "Rockets do massive damage to all vehicle units.",
      "The attack is highly effective against ships.",
      "The attack is highly effective against surfaced subs.",
      "This unit can no longer attack when it runs out of ammo.", "", "", "", ""]
  end
  
  def description
    return "A powerful indirect unit that can combat distant ground and sea units."
  end
end
$UNITS.push(Rocket)