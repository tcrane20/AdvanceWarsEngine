class LaserCannon < Structure
  
  def initialize(x,y)
		super(x,y)
		@name = "lasercannon"
		@id = TILE_JOINT
		@hp = 99
    @weakspot = [1,1]
    @range = -1
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
    sy = @y
    while $game_map.valid?(@x,sy+1)
      range.push([@x,sy+1])
      sy+=1
    end
    sy = @y
    while $game_map.valid?(@x,sy-1)
      range.push([@x,sy-1])
      sy-=1
    end
    sx = @x
    while $game_map.valid?(sx+1,@y)
      range.push([sx+1,@y])
      sx+=1
    end
    sx = @x
    while $game_map.valid?(sx-1,@y)
      range.push([sx-1,@y])
      sx-=1
    end
    return range
  end
  
  
end
