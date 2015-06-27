=begin
________________________
 UnitList_Window        \______________________________________________________
 
 Supposed to draw the units the army has in a list. Haven't started it yet.
 
 Notes:
 * 
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class UnitList_Window < Window_Base
  #-----------------------------------------------------------------------
  # Initialize the Unit List
  #-----------------------------------------------------------------------
  def initialize(units)
    super(58, 100, 460, 10+(32*7))
    #@active_mod_on = true
    @units = units
    self.contents = Bitmap.new(460, 32)
    @unit_list = Sprite.new
    @unit_list.bitmap = Bitmap.new(460, 32*units.size)
    @unit_list.src_rect = Rect.new(0,0,460,32*6)
    @unit_list.z = 10000
    @unit_list.x = 58
    @unit_list.y = 132
    @sprite_frame = Graphics.frame_count % 60 / 15
    @custom_update_method = true
    refresh
    @index = 0
    @top_index = 0
    self.active = true
    #Mouse.saved_window = self
  end
  #-----------
  # Refresh
  #-----------
  def refresh
    draw_header
    for i in 0...@units.size
      draw_unit_list(i)
    end
  end
  
  
  def draw_header
    self.contents.draw_text(64, 0, 100, 32, "Unit")
    self.contents.draw_text(164, 0, 32, 32, "HP")
    self.contents.draw_text(196, 0, 80, 32, "Gas")
    self.contents.draw_text(276, 0, 80, 32, "Rounds")
  end
  #----------------------------------------------------------------------
  # Refresh unit graphics
  #----------------------------------------------------------------------
  def refresh_graphics
    for i in 0...@units.size
      y = 32 * i
      # Erase the graphic at this spot
      @unit_list.bitmap.erase(32,y,32,32)
      # Redraw the unit graphic:
      # Get the unit value
      unit = @units[i]
      # Draw the unit graphic
      id = "_" + unit.army.id.to_s
      bitmap = RPG::Cache.character(unit.name + id, 0)
      opacity = 255
      opacity = 180 if unit.acted
      rect = Rect.new(@sprite_frame*32, 0, 32, 32)
      @unit_list.bitmap.blt(32, y, bitmap, rect, opacity)
    end
  end
  #-------------------------------------------------------------------------
  # Draws the unit graphic, unit name, and price
  #-------------------------------------------------------------------------
  def draw_unit_list(index)
    refresh_graphics
    # Get the unit value
    unit = @units[index]
    # Draw the unit's name and cost
    @unit_list.bitmap.draw_text(0, 32 * index, 32, 32, "#{index+1}")
    @unit_list.bitmap.draw_text(64, 32 * index, 100, 32, unit.real_name)
    @unit_list.bitmap.draw_text(164, 32 * index, 32, 32, "#{unit.unit_hp}", 2)
    @unit_list.bitmap.draw_text(196, 32 * index, 80, 32, "#{unit.fuel}/#{unit.max_fuel}",2)
    if unit.max_ammo == 0
      @unit_list.bitmap.draw_text(276, 32 * index, 80, 32, "Free",2)
    else
      @unit_list.bitmap.draw_text(276, 32 * index, 80, 32, "#{unit.ammo}/#{unit.max_ammo}",2)
    end
    
  end
  #-------------------------------------------------------------------------
  # Updates the window. Updates the unit graphics every frame
  #-------------------------------------------------------------------------
  def update
    super
    # If 10 frame counts have passed
    if @sprite_frame != Graphics.frame_count % 60 / 15
      # Update frame count
      @sprite_frame = Graphics.frame_count % 60 / 15
      # Update unit graphics to new animation frame
      refresh_graphics
    end
    
      
    if Input.repeat?(Input::DOWN)
      @index += 1 if @index < @units.size-1
      if Input.trigger?(Input::DOWN) && @index == @units.size
        @index = 0
        @top_index = 0
        @unit_list.src_rect.y = 0
      elsif @index > @top_index + 5
        @top_index += 1
        @unit_list.src_rect.y += 32
      end
      
    elsif Input.repeat?(Input::UP)
      @index -= 1 if @index > 0
      if Input.trigger?(Input::UP) && @index == -1
        @index = @units.size - 1
        @top_index = [@units.size - 6, 0].max
        @unit_list.src_rect.y = @top_index * 32
      elsif @index < @top_index
        @top_index -= 1
        @unit_list.src_rect.y -= 32
      end
    end
    
    self.cursor_rect.set(0, (@index - @top_index) * 32 + 32, self.width, 32)
    
  end
  #-------------------------------------------------------------------------
  # Returns the unit located at cursor index
  #-------------------------------------------------------------------------
  def unit
    return @units[@index]
  end
  
  
  def dispose
    super
    @unit_list.bitmap.dispose
    @unit_list.dispose
  end
  
end
