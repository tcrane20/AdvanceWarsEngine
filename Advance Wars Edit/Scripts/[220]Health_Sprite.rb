=begin
______________________
 Health_Sprite        \__________________________________________________________
 
 Draws the HP of the unit on the right corner of it.
 
 Notes:
 * Is this class necessary? Can't I append it to Unit Sprite?
 * Combine all flags and HP flags into one file
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Health_Sprite < RPG::Sprite
  
  def initialize(unit, viewport=nil)
    super(viewport)
    @unit = unit
    # Graphic location, based on pixels
    @x = @unit.x; @y = @unit.y
    # The map location of sprite; never changes unless the unit moves
    @oy = @y; @ox = @x 
    @anim_frame = @unit.frame
    #self.bitmap = Bitmap.new(16, 16)
		self.z = 22000
    moveto(@ox, @oy)
  end
  #----------------------------------------------------------------------------
  # MoveTo - sets the current X,Y location on the map; moves graphic there
  #----------------------------------------------------------------------------
  def moveto(x, y)
    @ox = @x = x
    @oy = @y = y  
    @real_x = @x * 128
    @real_y = @y * 128 
  end
  #--------------------------------------------------------------------------
  # Update the unit graphic
  #--------------------------------------------------------------------------
  def update
    super
    update_bitmap   # Update HP Graphic
    update_screen   # Update the position the graphic should be displayed
  end
  #--------------------------------------------------------------------------
  # Updates the animation frame
  #--------------------------------------------------------------------------
  def update_bitmap
		# Check if hiding HP from enemy view is true
		if @unit.army.officer.hide_hp and !@unit.army.playing
			self.bitmap = RPG::Cache.picture("hp_hide")
		else # Display normal HP value
			# If unit has damage on it
			if @unit.unit_hp < 10
				self.bitmap = RPG::Cache.picture("hp_" + @unit.unit_hp.to_s)
			# Otherwise, draw no flag
			else
				self.bitmap = nil
			end
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
    x = ((@real_x - $game_map.display_x + 3) / 4)+16
    return x
  end
  #----------------------------------------------------------------------------
  # Screen Y - sets Y based on current map position
  #----------------------------------------------------------------------------
  def screen_y
    y = ((@real_y - $game_map.display_y + 3) / 4 )+16
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
