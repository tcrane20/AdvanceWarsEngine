class BlackCannon < Structure
  
  def initialize(x,y, direction)
		super(x,y)
		@name = "blackcannon"
		@id = TILE_JOINT
		@hp = 99
    @size = [3,3]
    @weakspot = [2,3]
		@dir = direction
    @range = 10
	end
	
	def injure(amount, *args)
		super(amount)
		if @hp == 0
			# Change map graphic to destroyed graphic
			tile = $game_map.data[@x, @y, 0] + 2
			$game_map.data[@x, @y, 0] = tile
			# Change the tile data to Plains
			tile_type = Config.terrain_tag(tile, 0, 0, nil)
			$game_map.map_data[x,y].tile = tile_type
			#$spriteset.player_sprite.animation($data_animations[101], true)
			$game_player.animation_id = 101
		end
	end
  
  def attack_range
    range = []
    osx = 0
    osy = (@dir == 8 ? -1 : 1)
    sx,sy = osx, (osy == 1 ? 0 : osy*3)
    range.push([@x+sx,@y+sy])
    for i in 1...@range
      variance = -i
      sx += osx
      sy += osy
      if osx == 0
        while variance <= i
          range.push([@x+variance,@y+sy])
          variance += 1
        end
      else #osy == 0
        while variance <= i
          range.push([@x+sx,@y+variance])
          variance += 1
        end
      end
    end
    return range
  end
  
end
