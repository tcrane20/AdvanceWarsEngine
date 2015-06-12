class Silo < Property
  attr_accessor :launched
  def initialize(x, y, launched = false)
    super(x, y, 0)
		@name = 'silo'
    @id = TILE_SILO
    @launched = launched
    @capt = -1
    @ai_value = 1000
  end
  
  def launch
    # Notify that the silo has been launched
    @launched = true
    # Change the tile graphic accordingly (silo base should be one spot right to
    # the silo graphic on the tileset)
    tile = $game_map.data[@x, @y, 0] + 1
    $game_map.data[@x, @y, 0] = tile
    return if @y-1 < 0
    $game_map.data[@x, @y-1, 1] = tile - 8
  end
  
end
