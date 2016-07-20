################################################################################
# Class Missile
#   Cost : 10000                Move : 5      Move Type : Tire
#   Vision : 5                  Fuel : 60
#   Primary Weapon : Missile                  Ammo : 6
#   Secondary Weapon : None
################################################################################
class Missile < Unit
  def initialize(*args)
    super(*args)
    @name = "missile"
    @real_name = "Missiles"
    @unit_type = 7
    @cost = 10000
    @move = 5
    @move_type = 2
    @vision = 5
    @max_fuel = 60
    @fuel = 60
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Missile"
    @weapon1_effect = [0, 0, 0, 0, 2, 2]
    @min_range = 3
    @max_range = 5
    @star_energy = 100
    @move_se = "wheels"
    
    @stat_desc = ["Missile launchers can engage and destroy air units from large distances away.",
      "The movement of this unit is severly reduced due to the wheels it travels on.",
      "Missile launchers have incredible vision, capable of attacking units in its sight.",
      "The unit moves on fuel. It can no longer move if it drops to zero.",
      "Missile launchers fire missiles. It can attack air units from far away.",
      "A slightly damaged missile launcher can take down copters in one shot.",
      "Missile launchers can take down planes in one shot.", "", "",
      "This unit can no longer attack when it runs out of ammo.", "", "","", ""]
  end
  
  def description
    return "A potent indirect unit that can destroy air units from afar."
  end
end
$UNITS.push(Missile)