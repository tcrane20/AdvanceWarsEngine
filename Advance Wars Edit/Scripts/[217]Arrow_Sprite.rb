=begin
_____________________
 Arrow_Sprite        \__________________________________________________________
 
 A segment of the arrow path created from moving a unit.
 
 Notes:
 * Optimize
 * Combine all arrow graphics into one file
 * Needs animation still, if necessary
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
#===============================================================================
# Arrow Sprite - Each individual arrow used to draw the path your unit moves on
#===============================================================================
class Arrow_Sprite < RPG::Sprite

  #--------------------------------------------------------------------------
  # Initialize arrow sprite
  #   * type = String: u, d, l, r, h, v, lu, ld, ru, rd
  #       Shape of arrow (facing left, up, curving, straight, etc)
  #   * location = [x, y] 
  #       Where this sprite should be drawn at
  #--------------------------------------------------------------------------
  def initialize(viewport, type, location)
    super(viewport)
    # Gets the picture name of what to draw
    @type = "arrow_" + type
    # Where does this sprite get drawn at
    @x = location[0]; @y = location[1]
    @oy = @y; @ox = @x 
    self.bitmap = Bitmap.new(32, 32)
    @anim = false
    self.z = 10000
    moveto(@ox, @oy)
    refresh
  end
  #----------------------------------------------------------------------------
  # MoveTo - sets the current X,Y location on the map
  #----------------------------------------------------------------------------
  def moveto(x, y)
    @ox = @x = x
    @oy = @y = y
    @real_x = @x * 128
    @real_y = @y * 128
  end
  #----------------------------------------------------------------------------
  # Refresh - Process to update/set the bitmap for the object
  #----------------------------------------------------------------------------
  def refresh
    # get arrow bitmap (picture folder)
    self.bitmap = RPG::Cache.picture(@type)
    # define width and height (32 x 32)
    @cw = self.bitmap.width
    @ch = self.bitmap.height
    update
  end
  #--------------------------------------------------------------------------
  # Update the unit graphic
  #--------------------------------------------------------------------------
  def update
    super
 #   update_bitmap   # Not needed for now
    update_screen   # Update the position the graphic should be displayed
 #   update_frame    # Update the frame count (if wanted later)
  end
  #--------------------------------------------------------------------------
  # Updates the animation frame
  #--------------------------------------------------------------------------
  def update_bitmap
    ### The following commented lines may be used for animation frames ###
 #   # Get the graphic that represents the current frame
 #   sx = @unit.frame * @cw
 #   # Take the square graphic from the rectangular picture
 #   self.src_rect.set(sx, 0, @cw, @ch)
    self.src_rect.set(0, 0, @cw, @ch)
  end
  #--------------------------------------------------------------------------
  # Updates the frame count
  #--------------------------------------------------------------------------
  def update_frame
    # If animation frame is different, change graphic
    if @anim_frame != @unit.frame
      @anim_frame = @unit.frame
    end
  end
  #--------------------------------------------------------------------------
  # Updates the origin of the sprite (where it should be drawn)
  #--------------------------------------------------------------------------
  def update_screen
    self.x = screen_x unless self.disposed?
    self.y = screen_y unless self.disposed?
  end
  #----------------------------------------------------------------------------
  # Screen X - sets X based on current map position
  #----------------------------------------------------------------------------
  def screen_x
    x = ((@real_x - $game_map.display_x + 3) / 4)
    return x
  end
  #----------------------------------------------------------------------------
  # Screen Y - sets Y based on current map position
  #----------------------------------------------------------------------------
  def screen_y
    y = ((@real_y - $game_map.display_y + 3) / 4 ) 
    return y 
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
