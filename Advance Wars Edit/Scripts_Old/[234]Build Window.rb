=begin
_____________________
 Build_Window        \__________________________________________________________
 
 Selectable window that draws units available to buy. Basic, one column window.
 Draws animating unit sprites as well. Also handles the unit description window
 and short bio window. Good idea?
 
 Notes:
 * Look into optimizing it. Probably a lot of drawing going on.
 * Mouse transition to unit description window lacking
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Build_Window < Window_Selectable
  #-----------------------------------------------------------------------
  # Initialize the build window
  #     units - list of units to be drawn; stored in @commands
  #-----------------------------------------------------------------------
  def initialize(units)
    h = [units.size,8].min
    #super(58, 100, 220, 10+(32*h))
    super(30, 100, 248, 10+(32*h))
    @active_mod_on = true
    @units = units
    self.contents = Bitmap.new(250, 32*units.size)
    @item_max = units.size
    @sprite_frame = Graphics.frame_count % 60 / 15
    @info_window = Unit_Info_Window.new(@units[0])
    @desc_window = Description_Window.new
    refresh
    self.index = 0
    self.active = true
    @desc_window.draw_info(@units[@index].stat_desc[0])
    @info_window.set_desc_window(@desc_window)
    self.z = 10000
  end
  #-----------
  # Refresh
  #-----------
  def refresh
    for i in 0...@units.size
      draw_unit_list(i)
    end
  end
  #----------------------------------------------------------------------
  # Refresh unit graphics
  #----------------------------------------------------------------------
  def refresh_graphics
    for i in 0...@units.size
      y = 32 * (i+1) - 32
      # Erase the graphic at this spot
      self.contents.erase(0,y,32,32)
      # Redraw the unit graphic:
      # Get the unit value
      unit = @units[i]
      # Draw the unit graphic
      id = "_" + unit.army.id.to_s
      bitmap = RPG::Cache.character(unit.name + id, 0)
      opacity = 255
      opacity = 180 if unit.army.funds < unit.cost(true)
      rect = Rect.new(@sprite_frame*32, 0, 32, 32)
      self.contents.blt(0, y, bitmap, rect, opacity)
    end
  end
  #-------------------------------------------------------------------------
  # Draws the unit graphic, unit name, and price
  #-------------------------------------------------------------------------
  def draw_unit_list(index)
    # Get the unit value
    unit = @units[index]
    # Draw the unit graphic
    id = "_" + unit.army.id.to_s
    bitmap = RPG::Cache.character(unit.name + id, 0)
    y = 32 * (index+1) - 32
    rect = Rect.new(@sprite_frame*32, 0, 32, 32)
    # Reset the font and unit opacity
    opacity = 255
    self.contents.font.color = Color.new(0,0,0,255)
    if unit.army.funds < unit.cost(true)
      opacity = 180
      self.contents.font.color = Color.new(0,0,0,128)
    end
    self.contents.blt(0, y, bitmap, rect, opacity)
    # Draw the unit's name and cost
    draw_text_indent(index+1, unit.real_name)
    draw_text_indent(index+1, unit.cost(true).to_s, 125)
  end
  #-------------------------------------------------------------------------
  # Updates the window. Updates the unit graphics every frame
  #-------------------------------------------------------------------------
  def update
    prev_index = @index
    # If 10 frame counts have passed
    if @sprite_frame != Graphics.frame_count % 60 / 15
      # Update frame count
      @sprite_frame = Graphics.frame_count % 60 / 15
      # Update unit graphics to new animation frame
      refresh_graphics
    end
    
    @info_window.update if @info_window.active
    super if self.active
    
    if self.active
      @info_window.unit = @units[@index] if prev_index != @index
      @desc_window.draw_info(@units[@index].stat_desc[0]) if prev_index != @index
      
      if Input.trigger?(Input::RIGHT)
        $game_system.se_play($data_system.cursor_se)
        self.cursor_rect.visible = false
        self.active = false
        @info_window.active = true
        @info_window.cursor_rect.visible = true
      end
    else # Info Window is active
      if Input.trigger?(Input::LEFT) or Input.trigger?(Input::B)
        $game_system.se_play($data_system.cursor_se)
        self.cursor_rect.visible = true
        self.active = true
        @info_window.index = 0
        @info_window.active = false
        @info_window.cursor_rect.visible = false
        # Reset description window to brief unit profile
        @desc_window.draw_info(@units[@index].stat_desc[0])
      end
    end
  end
  #-------------------------------------------------------------------------
  # Dispose self and info window
  #-------------------------------------------------------------------------
  def dispose
    @info_window.dispose
    @desc_window.dispose
    super
  end
  #-------------------------------------------------------------------------
  # Builds a unit
  #-------------------------------------------------------------------------
  def build_unit
    x, y = $game_player.x, $game_player.y
    unit.x, unit.y = x, y
    unit.init_sprite
    unit.army.add_unit(unit)
    unit.army.funds -= unit.cost(true)
  end
  #-------------------------------------------------------------------------
  # Returns the unit located at cursor index
  #-------------------------------------------------------------------------
  def unit
    return @units[@index]
  end
  
  
  
end
