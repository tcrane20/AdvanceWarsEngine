class Pipe_Joint < Structure
  
  def initialize(x,y, horizontal = true)
    super(x,y)
    @name = "pipejoint"
    @id = TILE_JOINT
    @hp = 99
    @weakspot = [1,1]
    @dir = (horizontal ? "h" : "v")
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
  
end