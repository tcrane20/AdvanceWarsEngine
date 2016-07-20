=begin
_____________________
 Tile_Graphic        \__________________________________________________________
 
 Draws the currently highlighted tile the cursor is over in the stat window
 at the bottom. Also shows terrain defense and capture points or health points
 if applicable.
 
 Notes:
 * Redrawn every frame
 * Needs tile name (kinda implemented)
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Tile_Graphic < RPG::Sprite
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def initialize(viewport=nil)
    super(viewport)
    # Where does this sprite get drawn at
    self.bitmap = Bitmap.new(64, 96)
    # Create offset
    self.x = 0
    self.y = 480 - 96
  end
  #--------------------------------------------------------------------------
  # Update the tile graphic
  #--------------------------------------------------------------------------
  def update
    super
    update_graphic   # Changes the tile to draw
  end
  #--------------------------------------------------------------------------
  # Changes the tile graphic if needed
  #--------------------------------------------------------------------------
  def update_graphic
    self.bitmap.clear
    # Load tile id and get graphic to draw
    tile_id = $spriteset.fow_tilemap.map_data[$game_player.x, $game_player.y, 0] if $game_map.fow
    tile_id = $game_map.data[$game_player.x, $game_player.y, 0] if (tile_id.nil? or tile_id == 0)
    
    tile = $game_map.get_tile($game_player.x,$game_player.y)
    bitmap = RPG::Cache.tile($game_map.tileset_name, tile_id, 0)
    rect = Rect.new(0, 0, 32, 32)
    self.bitmap.blt(16, 16, bitmap, rect)
    # Centers the name
=begin
    bitmap = RPG::Cache.picture(tile.name)
    add = (64 - bitmap.width) / 2
    rect = Rect.new(0, 0, 50, 32)
    self.bitmap.blt(add, 4, bitmap, rect)
=end
    # Create the terrain star graphic
    bitmap = RPG::Cache.picture("info_tdef")
    rect = Rect.new(0, 0, 20, 20)
    self.bitmap.blt(8, 50, bitmap, rect)
    # Draw the terrain's defense number
    rect = Rect.new(0, 0, 12, 14)
    stars = [tile.defense + $scene.player.officer.terrain_stars(tile) - $scene.player.reduced_terrain_stars, 0].max
    bitmap = RPG::Cache.picture("info_" + (stars).to_s)
    self.bitmap.blt(40, 54, bitmap, rect)
    # Create capture points if tile is property related
    if tile.is_a?(Property) and !tile.is_a?(Silo)
      bitmap = RPG::Cache.picture("info_capt")
      rect = Rect.new(0, 0, 20, 24)
      self.bitmap.blt(8, 70, bitmap, rect)
      # Draw the capture points
      rect = Rect.new(0, 0, 12, 14)
      if tile.capt >= 10
        bitmap = RPG::Cache.picture("info_" + (tile.capt/10).to_s)
        self.bitmap.blt(28, 75, bitmap, rect)
      end
      bitmap = RPG::Cache.picture("info_" + (tile.capt%10).to_s)
      self.bitmap.blt(40, 75, bitmap, rect)
    elsif tile.is_a?(Structure) and tile.hp > 0
      bitmap = RPG::Cache.picture("info_heart")
      rect = Rect.new(0, 0, 12, 12)
      self.bitmap.blt(11, 75, bitmap, rect)
      # Draw the capture points
      rect = Rect.new(0, 0, 12, 14)
      if tile.hp >= 10
        bitmap = RPG::Cache.picture("info_" + (tile.hp/10).to_s)
        self.bitmap.blt(28, 75, bitmap, rect)
      end
      bitmap = RPG::Cache.picture("info_" + (tile.hp%10).to_s)
      self.bitmap.blt(40, 75, bitmap, rect)
    end
    
  end
  #----------------------------------------------------------------------------
  # Dispose process
  #----------------------------------------------------------------------------
  def dispose
    unless self.bitmap == nil
      self.bitmap.dispose
      self.bitmap = nil
    end
    super
  end
  
end

