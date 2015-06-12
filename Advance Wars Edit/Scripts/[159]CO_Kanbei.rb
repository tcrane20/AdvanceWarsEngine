################################################################################
# Class Kanbei
#   Army: Yellow Comet           Power Bar: x x x x X X X
#
# - 120/120 Units
# - 120% deployment costs
#
# Power: Morale Boost
# - 150/130 Units
# - 170/130 Units when counter attacking
#
# Super Power: Samurai Spirit
# - 150/150 Units
# - 200/150 Units when counter attacking
#   
################################################################################
class CO_Kanbei < CO
  def initialize(army=nil)
    super(army)
    @name = "Kanbei"
    @cop_name = "Morale Boost"
    @scop_name = "Samurai Spirit"
    @description = [
    "Yellow Comet", "Honor, Sonja", "Computers",
    "The great emperor of Yellow Comet. Battle-minded and honorable. Has a soft spot for his daughter Sonja.",
    "All units have superior offense and defense capabilities. However, they are more expensive to deploy.",
    "Raises the firepower of his units. Counter attack damage is increased.",
			"Raises the firepower and defense of his units. Counter attack damage is doubled.",
		"Emperor of Yellow Comet. Units have high stats but cost more. Powers increase firepower, defense, and counter attacks."]
    @cop_stars = 4
    @scop_stars = 7
		@cost_multiplier = 110
  end
  
  def atk_bonus(unit)
    if @scop or @cop
			if !@army.playing
				return 200 if @scop
				return 175 if @cop
			end
      return 150
    else
      return 125
    end
  end
  
	def def_bonus(unit)
		if @scop
			return 150
		elsif @cop
			return 135
		else
			return 125
		end
	end
	
end
$CO.push(CO_Kanbei)