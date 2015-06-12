class Woods < Tile
	def initialize
		super
		@name = 'woods'
		@id = TILE_WOODS
		@defense = 2
		@fow_cover = true
	end

	def move_cost(unit)
		if ($game_map.current_weather == 'snow' and !unit.army.officer.no_snow_penalty) or
			($game_map.current_weather == 'rain' and unit.army.officer.name == 'Olaf')
			case unit.move_type
			when MOVE_FOOT then return 2
			when MOVE_MECH then return 2
			when MOVE_TIRE then return 4
			when MOVE_TREAD then return 3
			when MOVE_AIR then return 2
			when MOVE_TRANS then return 0
			when MOVE_SEA then return 0
			when MOVE_TIRE_B then return 4
			end
		elsif $game_map.current_weather == 'rain' and !unit.army.officer.no_rain_penalty
			# Rain movechart
			case unit.move_type
			when MOVE_FOOT then return 1
			when MOVE_MECH then return 1
			when MOVE_TIRE then return 4
			when MOVE_TREAD then return 3
			when MOVE_AIR then return 1
			when MOVE_TRANS then return 0
			when MOVE_SEA then return 0
			when MOVE_TIRE_B then return 4
			end
		else
			case unit.move_type
			when MOVE_FOOT then return 1
			when MOVE_MECH then return 1
			when MOVE_TIRE then return 3
			when MOVE_TREAD then return 2
			when MOVE_AIR then return 1
			when MOVE_TRANS then return 0
			when MOVE_SEA then return 0
			when MOVE_TIRE_B then return 3
			end
		end
	end
end