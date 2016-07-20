class Window_Command < Window_Selectable
  attr_reader :commands, :unit
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     width    : window width
  #     commands : command text string array
  #     icons    : if this window uses icons for its commands
  #      unit      : needed to draw units being carried for 'Drop' purposes
  #--------------------------------------------------------------------------
  def initialize(width, commands, icons = false, unit = nil)
    # Compute window height from command quantity
    super(0, 0, width, commands.size * 32 + 8)
    @icons = icons
    @unit = unit
    @item_max = commands.size
    @commands = commands
    
    self.contents = Bitmap.new(@width, @height)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # Returns the data value located at current index
  #--------------------------------------------------------------------------
  def at_index
    return @commands[@index]
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #     color : text color
  #--------------------------------------------------------------------------
  def draw_item(index, color = Color.new(0,0,0))
    self.contents.font.color = color
    if !@icons
      draw_text(index+1, @commands[index])
    else
      icon = ""
      unless @commands[index] == "Drop" or @commands[index] == "Drop "
        icon = Config.get_command_icon(@commands[index])
        draw_text_icon(index+1, @commands[index], icon)
      else
        # Get the correct unit when drawing the "Drop" command(s)
        held_unit = @unit.holding_units[0] if @commands[index] == "Drop"
        held_unit = @unit.holding_units[1] if @commands[index] == "Drop "
        # Get the held unit's bitmap
        id = "_" + held_unit.army.id.to_s
        bitmap = RPG::Cache.character(held_unit.name + id, 0)
        y = 32 * (index+1) - 32
        rect = Rect.new(0,0,bitmap.width/4,bitmap.height)
        self.contents.blt(0, y, bitmap, rect)
        
        # Get held unit's flag
        if held_unit.holding_units.size > 0 or held_unit.hiding
          bitmap = RPG::Cache.picture("load") if @unit.holding_units.size > 0
          bitmap = RPG::Cache.picture("hide") if @unit.hiding
          rect = Rect.new(0,0,bitmap.width,bitmap.height)
          self.contents.blt(0, y+16, bitmap, rect)
        end
        
        # If unit has damage on it
        if held_unit.unit_hp < 10
          bitmap = RPG::Cache.picture("hp_" + held_unit.unit_hp.to_s)
          rect = Rect.new(0,0,bitmap.width,bitmap.height)
          self.contents.blt(16, y+16, bitmap, rect)
        end
        draw_text_indent(index+1, "Drop")
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Set Window X- and Y- Coords
  #--------------------------------------------------------------------------
  def set_at(x, y)
    self.x = x
    self.x = 0 if x < 0
    self.y = y
    if x + self.width > 640
      self.x -= (x + self.width - 640)
    end
    if y + self.height > 480
      self.y -= (y + self.height - 480)
    end
  end
  
end
