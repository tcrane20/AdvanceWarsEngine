################################################################################
# Class AntiAir
#   Cost : 8000                 Move : 6      Move Type : Tread
#   Vision : 3                  Fuel : 70
#   Primary Weapon : Vulcan                   Ammo : 9
#   Secondary Weapon : None
################################################################################
class AntiAir < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "antiair"
		@real_name = "Anti-Air"
    @unit_type = 6
    @cost = 8000
    @move = 6
    @move_type = 3
    @vision = 3
    @max_fuel = 70
    @fuel = 70
    @max_ammo = 9
    @ammo = 9
		@weapon1 = "Vulcan"
		@weapon1_effect = [2, 1, 0, 0, 2, 2]
    @star_energy = 60
    @move_se = "tread"
		
		@stat_desc = ["Anti-Air units can directly engage air units for superb damage.",
			"This unit moves a far distance. The unit travels on treads.",
			"This is the unit\'s vision in Fog of War.",
			"The unit moves on fuel. It can no longer move if it drops to zero.",
			"Anti-Air attack with a high-powered vulcan.",
			"Anti-Air can do devastating damage to infantry units.",
			"The attack deals somewhat good damage to non-tank units.",
			"Copter units will usually be destroyed in one shot by an anti-air.",
			"Anti-Air can do impressive damage to bombers if it attacks first.",
			"This unit can no longer attack when it runs out of ammo.", "", "","", ""]
  end
  
  def description
    return "A ground unit that has superb attacking capabilites against air units."
  end
end
$UNITS.push(AntiAir)