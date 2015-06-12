################################################################################
# Class Olaf
#   Army: Blue Moon           Power Bar: x x x X X X X
#
# - 120/100 Units in snow and unaffected by move penalties
# - 90/100 Units in rain and move as if it were snow
#
# Power: Blizzard
# - Summons a 2 day snowstorm
#
# Super Power: Winter Fury
# - 2 HP mass damage
# - Summons a 1 day snowstorm
#   
################################################################################
class CO_Olaf < CO
  def initialize(army=nil)
		super(army)
		@name = "Olaf"
		@cop_name = "Blizzard"
		@scop_name = "Winter Fury"
		@description = [
			"Blue Moon", "Warm Coat", "Rain Boots",
			"The commander-in-chief of Blue Moon. While a braggart, he has gained the respect of his peers and his people.",
			"Snow does not impede the movement of his troops. Rain bogs his units down and weakens them.",
			"Causes a snowstorm that lasts for 2 days.",
			"Damages all enemy units for 2 HP. Causes a snowstorm for 1 day.",
			"Commander of Blue Moon. Units perform well in snow but terrible in rain. Powers create blizzards, impairing and damaging enemy units."]
		@cop_stars = 3
		@scop_stars = 7
		@no_snow_penalty = true
	end
	
	def atk_bonus(unit)
		case $game_map.current_weather
		when 'rain'
			return 90
		else
			return 100
		end
	end
	
	def use_cop
		super
		$game_map.set_weather('snow', 2)
	end
	
	def use_scop
		super
		$game_map.set_weather('snow', 1)
		mass_damage(2, $game_map.units - @army.units)
	end
	
  
end
$CO.push(CO_Olaf)