################################################################################
# Class Neotank
#   Cost : 20000                Move : 6      Move Type : Tread
#   Vision : 1                  Fuel : 50
#   Primary Weapon : Neo Cannon               Ammo : 6
#   Secondary Weapon : Machine Gun
################################################################################
class Neotank < Unit
  def initialize(*args)
    super(*args)
    @name = "neotank"
    @real_name = "Neotank"
    @unit_type = NEO
    @cost = 20000
    @move = 6
    @move_type = MOVE_TREAD
    @max_fuel = 50
    @fuel = 50
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Neocannon"
    @weapon2 = "Machine Gun"
    @weapon1_effect = [0, 2, 1, 1, 0, 0]
    @weapon2_effect = [2, 1, 0, 0, 1, 0]
    @star_energy = 150
    @move_se = "m_tread"
    
    @stat_desc = ["An invention of Black Hole, Neotanks are even stronger than medium tanks.",
      "Neotanks move further than medium tanks. The unit travels on treads.",
      "The vision range of this unit is pitiful.",
      "The unit moves on fuel. It can no longer move if it drops to zero.",
      "Neotanks are armed with the alien neocannons. It\'s quite potent in power.",
      "Neotanks can cripple medium tanks and wipe out most vehicles in one attack.",
      "The attack does not do much damage to ships.",
      "The attack does not do much damage to surfaced subs.", "",
      "Neotanks are armed with machine guns when their primary weapon runs out of ammo.",
      "Neotanks can wipe out infantry units in one shot.",
      "The attack is effective against indirect-attacking vehicles.",
      "The attack is effective against transport copters.", ""]
  end
  
  def description
    return "An invention of the Black Hole that deals horrific damage."
  end
end
$UNITS.push(Neotank)