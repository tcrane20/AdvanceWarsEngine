################################################################################
# Class Hawke
#   Army: Black Hole           Power Bar: x x x x X X X X
#
# - 110/100 Units
# - The charge rate of his Power Bar decreases faster than other COs
#
# Power: Black Wave
# - All units are healed 1 HP
# - 1 HP Mass damage
#
# Super Power: Black Storm
# - All units are healed 2 HP
# - 2 HP Mass damage
#   
################################################################################
class CO_Hawke < CO
  def initialize(army=nil)
    super(army)
    @name = "Hawke"
    @cop_name = "Black Wave"
    @scop_name = "Black Storm"
    @description = [
    "Black Hole", "Black Coffee", "Incompetence",
    "Black Hole's commander-in-chief. He will stop at nothing to get what he wants.",
    "Commands his forces with authority. All units have raised firepower. However, the charge rate for his CO Powers reduces faster than other COs.",
    "All units restore 1 HP. All enemy units lose 1 HP.",
			"All units restore 2 HP. All enemy units lose 2 HP.",
		"All units have increased power. CO bar charges slowly the more times it is used. Powers damage enemy units while healing his own."]
    @cop_stars = 4
    @scop_stars = 8
  end
  
  def atk_bonus(unit)
    return 110
  end
  
	def use_cop
		super
		mass_heal(1, @army.units)
		mass_damage(1, $game_map.units - @army.units)
		@army.recharge_rate -= 5 if @army.recharge_rate > 50
	end
	
	def use_scop
		super
		mass_heal(2, @army.units)
		mass_damage(2, $game_map.units - @army.units)
		@army.recharge_rate -= 5 if @army.recharge_rate > 50
	end
	
end
$CO.push(CO_Hawke)