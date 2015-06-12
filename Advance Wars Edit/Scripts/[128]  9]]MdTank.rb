################################################################################
# Class MdTank
#   Cost : 16000                Move : 5      Move Type : Tread
#   Vision : 2                  Fuel : 50
#   Primary Weapon : Cannon                   Ammo : 6
#   Secondary Weapon : Machine Gun
################################################################################
class MdTank < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "midtank"
		@real_name = "Med. Tank"
    @unit_type = 9
    @cost = 14000
    @move = 5
    @move_type = 3
    @vision = 2
    @max_fuel = 50
    @fuel = 50
    @max_ammo = 8
    @ammo = 8
		@weapon1 = "Cannon"
		@weapon2 = "Machine Gun"
		@weapon1_effect = [0, 2, 1, 1, 0, 0]
		@weapon2_effect = [2, 1, 0, 0, 1, 0]
    @star_energy = 125
    @move_se = "m_tread"
		
		@stat_desc = ["Medium tanks are bigger, slower, and much stronger than it\'s predecessor.",
			"Medium tanks don't move as far as tanks. The unit travels on treads.",
			"The vision range of this unit is somewhat lacking.",
			"The unit moves on fuel. It can no longer move if it drops to zero.",
			"Medium tanks attack with powerful cannons. It does more damage than a tank\'s.",
			"Medium tanks can wipe out some smaller vehicles in one shot.",
			"The attack does not do much damage to ships.",
			"The attack does not do much damage to surfaced subs.", "",
			"Medium tanks are armed with machine guns when their primary weapon runs out of ammo.",
			"A medium tank\'s machine gun is stronger than a recon\'s.",
			"The attack is somewhat effective against indirect-attacking vehicles.",
			"The attack is effective against transport copters.", ""]
  end
  
  def description
    return "An upgraded tank that can deal massive damage to land units."
  end
end
$UNITS.push(MdTank)