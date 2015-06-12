################################################################################
# Class Sonja
#   Army: Yellow Comet           Power Bar: x x x X X 
#
# - +1 Vision for all units
# - No positive luck
#
# Power: Enhanced Vision
# - +2 Vision for all units
# - Hiding places are revealed in fog of war
#
# Super Power: Counter Break
# - Units strike first when counter attacking
# - Unit HP is hidden from the enemy
#   
################################################################################
class CO_Sonja < CO
	def initialize(army=nil)
    super(army)
    @name = "Sonja"
    @cop_name = "Enhanced Vision"
    @scop_name = "Counter Break"
    @description = [
    "Yellow Comet", "Computers", "Bugs",
    "Kanebi's intelligent daughter. Her calm and focused personality makes her great at finding enemy intel.",
    "To gather more intel of her surroundings, her units have additional vision. Unit HP is hidden from enemy players. Damage readings are completely accurate.",
    "Units receive additional vision. Their vision can also pierce thick terrain in FOW.",
			"Reduces enemy terrain defenses by 2. Units counter attack first before the enemy.",
		"Units have greater vision and hidden HP values. Attacks do not have luck damage. Powers increase vision and allow first-strike counter attacks."]
    @cop_stars = 3
    @scop_stars = 5
		@hide_hp = true
  end
  
	def vision_bonus(unit)
		return 2 if @cop
		return 1
	end
	
	def luck_bonus(unit)
		return 1
	end
	
	def use_cop
		super
		@pierce_fow = true
	end
	
	def cop=(bool)
		if @cop
			@pierce_fow = false
		end
		@cop = bool
	end
	
	def use_scop
		super
		($game_map.army - [@army]).each{|army|
			army.reduced_terrain_stars += 2
		}
		@first_counter = true
	end
	
	def scop=(bool)
		if @scop
		($game_map.army - [@army]).each{|army|
			army.reduced_terrain_stars -= 2
			}
		end
		@scop = bool
		@first_counter = bool
	end
  
end
$CO.push(CO_Sonja)