################################################################################
# Class Koal
#   Army: Black Hole           Power Bar: x x x X X
#
# - 110/110 Units on Roads/Bridges
#
# Power: Forced March
# - 130/130 Units on Roads/Bridges
# - +1 Move
#
# Super Power: Trail of Woe
# - 140/140 Units on Roads/Bridges
# - +2 Move
#   
################################################################################
class CO_Koal < CO
	def initialize(army=nil)
		super(army)
		@name = "Koal"
		@cop_name = "Forced March"
		@scop_name = "Trail of Woe"
		@description = [
			"Black Hole", "Ramen", "Fondue",
			"",
			"Koal knows how to utilize roads to his advantage. Units have increased stats when on roads.",
			"All units move 1 space further. They also receive a offense and defense bonus on roads.",
			"All units move 2 spaces further. They also receive a bigger offense and defense bonus on roads.",
		"Units on roads have improved attack and defense. Powers increase unit movement and road bonuses."]
		@cop_stars = 3
		@scop_stars = 5
	end
	
	def atk_bonus(unit)
		# Define roads bonus
		if @army.playing
			tile = $game_map.get_tile($scene.decided_spot_x, $scene.decided_spot_y)
		else
			tile = $game_map.get_tile(unit.x, unit.y)
		end
		if tile.is_a?(Road) or tile.is_a?(Bridge)
			if @scop
				return 140
			elsif @cop
				return 130
			else
				return 110
			end
		end
		return 100
	end
	
	def def_bonus(unit)
		if @army.playing
			tile = $game_map.get_tile($scene.decided_spot_x, $scene.decided_spot_y)
		else
			tile = $game_map.get_tile(unit.x, unit.y)
		end
		if tile.is_a?(Road) or tile.is_a?(Bridge)
			if @scop
				return 140
			elsif @cop
				return 130
			else
				return 110
			end
		end
		if @scop
			return 120
		elsif @cop
			return 110
		else
			return 100
		end
	end
	
	def move_bonus(unit)
		if @scop
			return 2
		elsif @cop
			return 1
		else
			return 0
		end
	end
end
$CO.push(CO_Koal)