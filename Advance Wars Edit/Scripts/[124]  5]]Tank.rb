################################################################################
# Class Tank
#   Cost : 7000                 Move : 6      Move Type : Tread
#   Vision : 3                  Fuel : 70
#   Primary Weapon : Cannon                   Ammo : 9
#   Secondary Weapon : Machine Gun
################################################################################
class Tank < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "tank"
		@real_name = "Tank"
    @unit_type = TNK
    @cost = 7000
    @move = 6
    @move_type = MOVE_TREAD
    @vision = 3
    @max_fuel = 70
    @fuel = 70
    @max_ammo = 9
    @ammo = 9
		@weapon1 = "Cannon"
		@weapon2 = "Machine Gun"
		@weapon1_effect = [0, 2, 1, 1, 0, 0]
		@weapon2_effect = [2, 1, 0, 0, 1, 0]
    @star_energy = 60
    @move_se = "tread"
		
		@stat_desc = ["Tanks are a versatile unit. They deal solid damage and have great mobility.",
			"This unit moves a far distance. The unit travels on treads.",
			"Tanks have a fairly good vision range.",
			"The unit moves on fuel. It can no longer move if it drops to zero.",
			"Tanks attack with cannons. They can engage many ground targets.",
			"Tanks do great damage against all vehicles except larger tanks.",
			"Tanks do not do much damage to ships.",
			"Tanks do low damage to surfaced subs.", "",
			"Tanks are armed with machine guns when their primary weapon runs out of ammo.",
			"A tank\'s machine gun is not quite as powerful as a recon\'s against infantry units.",
			"The attack is somewhat effective against indirect-attacking vehicles.",
			"The attack is somewhat effective against transport copters.", ""]
  end
  
  def description
    return "A standard vehicle unit that can combat many ground units."
  end
end
$UNITS.push(Tank)