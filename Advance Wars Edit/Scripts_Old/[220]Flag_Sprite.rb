=begin
____________________
 Flag_Sprite        \___________________________________________________________
 
 Draws the action (capture, hide, carry) of the unit on the left corner of it.
 Also draws low fuel/ammo indicators.
 
 Notes:
 * Is this class necessary? Can't I append it to Unit Sprite?
 * Combine all flags and HP flags into one file
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Flag_Sprite < RPG::Sprite
  
  def initialize(unit, viewport=nil)
    super(viewport)
    @unit = unit
    # Graphic location, based on pixels
    @x = @unit.x; @y = @unit.y
    # The map location of sprite; never changes unless the unit moves
    @oy = @y; @ox = @x 
    @anim_frame = @unit.frame
    #self.bitmap = Bitmap.new(16, 16)
    self.z = 1000
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
    update_bitmap   # Update flag graphic
    update_screen   # Update the position the graphic should be displayed
    update_frame    # Update the frame count (and also the low supplies graphics)
  end
  #--------------------------------------------------------------------------
  # Updates the animation frame
  #--------------------------------------------------------------------------
  def update_bitmap
    # If unit has these conditions
    if @unit.capturing or @unit.holding_units.size > 0 or @unit.hiding or @unit.disabled
      self.bitmap = RPG::Cache.picture("capture") if @unit.capturing
      self.bitmap = RPG::Cache.picture("load") if @unit.holding_units.size > 0
      self.bitmap = RPG::Cache.picture("hide") if @unit.hiding
      self.bitmap = RPG::Cache.picture("disable") if @unit.disabled
    # Otherwise, draw no flag
    else
      self.bitmap = nil
    end
  end
  #--------------------------------------------------------------------------
  # Updates the frame count
  #--------------------------------------------------------------------------
  def update_frame
    # If animation frame is different, change graphic
    if @anim_frame != @unit.frame
      @anim_frame = @unit.frame
    end
    case @anim_frame
    when 2
      if @unit.fuel / @unit.max_fuel.to_f <= 0.5
        self.bitmap = RPG::Cache.picture("lowfuel")
      end
    when 3
      if @unit.ammo / @unit.max_ammo.to_f <= 0.34
        self.bitmap = RPG::Cache.picture("lowammo")
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
    x = ((@real_x - $game_map.display_x + 3) / 4)
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
