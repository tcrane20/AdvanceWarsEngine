################################################################################
# Class Titus
#   Army: White Nova          Power Bar: x x x x X X X
#
# - 80/130 Units
#
# Power: Defense Up
# - 80/200 Units
# - +20 Defense luck
#
# Super Power: Wall of Infinity
# - 80/200 Units
# - +20 Defense luck
# - Units must sustain 1 HP before they can be destroyed
#   
################################################################################
class CO_Titus < CO
  def initialize(army=nil)
    super(army)
    @name = "Titus"
    @cop_name = "Defense Up"
    @scop_name = "Wall of Infinity"
    @description = [
    "Orange Star", "Indoors", "Outdoors",
    "A new commander of the new White Nova. Independent yet willing to help others in need.",
    "A true master of tactics, he knows great defensive procedures. However, the firepower of his units is very weak.",
    "Raises the defense of his units. Enemy attacks tend to do less damage than expected.",
    "Raises the defense of his units. Units must sustain 1 HP before they can be destroyed in combat.",
    "Units have high defense but low offense. Powers improve defenses."]
    @cop_stars = 4
    @scop_stars = 7
  end
	
	def atk_bonus(unit)
    return 80
	end
	
	def def_bonus(unit)
		if @scop or @cop
			return 200
		else
			return 130
		end
	end
	
	def def_luck_bonus(unit)
		if @cop or @scop
			return 20
		else
			return 0
		end
	end
  
	def use_scop
		super
		@last_stand = true
	end
	
	def scop=(bool)
		@scop = bool
		@last_stand = bool
	end
	
	
end
$CO.push(CO_Titus)