################################################################################
# Class Recon
#   Cost : 4000                 Move : 8      Move Type : Tire
#   Vision : 5                  Fuel : 80
#   Primary Weapon : None                     Ammo : N/A
#   Secondary Weapon : Machine Gun
################################################################################
class Recon < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "recon"
		@real_name = "Recon"
    @unit_type = 2
    @cost = 4000
    @move = 8
    @move_type = 2
    @vision = 5
    @max_fuel = 80
    @fuel = 80
    @star_energy = 50
		@weapon2 = "Machine Gun"
		@weapon2_effect = [2, 1, 0, 0, 1, 0]
    @move_se = "wheels"
		
		@stat_desc = ["Recons have high mobility and vision making them good for gathering intel.",
			"Although they move far, their wheels slow them down on non-urban terrain.",
			"Recons have a very large vision. They can help greatly in Fog of War.",
			"The unit moves on fuel. It can no longer move if it drops to zero.",
			"This unit has no primary weapon.",
			"", "", "", "",
			"The secondary weapon is a machine gun. It is actually quite powerful.",
			"Recons do massive damage to infantry units.",
			"The attack is somewhat effective against indirect-attacking vehicles.",
			"The attack is quite effective against transport copters.",
			""]
  end
  
  def description
    return "A highly mobile vehicle that can see far distances."
  end
end
$UNITS.push(Recon)