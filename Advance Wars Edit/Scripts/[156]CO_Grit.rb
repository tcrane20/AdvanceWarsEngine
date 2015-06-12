################################################################################
# Class Grit
#   Army: Blue Moon           Power Bar: x x x X X X
#
# - 110/100 and +1 range indirect combat Units
# - 80/100 non-infantry direct combat Units
#
# Power: Snipe Attack
# - 130/110 and +2 range indirect combat Units
#
# Super Power: Super Snipe
# - 150/120 and +3 range indirect combat Units
#
################################################################################
class CO_Grit < CO
	def initialize(army=nil)
		super(army)
		@name = "Grit"
		@cop_name = "Snipe Attack"
		@scop_name = "Super Snipe"
		@description = [
			"Blue Moon", "Cats", "Rats",
			"A cowboy at heart who has a passion for firearms. Lazy attitude but extremely dependable, especially towards Olaf.",
			"Indirect units have greatly improved firepower. Non-infantry direct combat units are severly weakened.",
			"Indirect units can fire 2 spaces further.",
			"Indirect units can fire 3 spaces further and have increased firepower.",
			"Indirect units do more damage but suffers in direct-combat. Powers increase indirect attack range and firepower."]
		@cop_stars = 3
		@scop_stars = 6
	end
	
	def atk_bonus(unit)
		return 100 if INFANTRY.include?(unit.unit_type)
		if unit.max_range(false) > 1
			if @scop
				return 140
			else
				return 120
			end
		else
			return 80
		end
	end
	
	def range_bonus(unit)
		return 0 if unit.max_range(false) == 1
		if @scop
			return 3
		elsif @cop
			return 2
		else
			return 0
		end
	end
	
	
end
$CO.push(CO_Grit)