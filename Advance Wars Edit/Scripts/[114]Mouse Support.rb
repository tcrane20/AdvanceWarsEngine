__END__
#===============================================================================
# ** MOUSIE!  The Mouse system
#===============================================================================
#    Version 2.0
#    by DerVVulfman (Window Edits by Lambchop)
#    March 19, 2009
#===============================================================================
#
#   SETTING UP THE MOUSE ICON SYSTEM
#
#   Mouse icons are stored in a hash array.
#
#   The system is designed  so you can create  your custom names or handles for
#   each mouse cursor/icon, let alone assign the custom icon(s) for your mouse.
#
#   Custom handles are string values  that you can use  in map events to change
#   the appearance of the 'mouse' when it is over same said event.  Each handle
#   is tagged to an icon filename.   When the mouse is dragged over a map event
#   with this handle  in the required 'comment',  the cursor itself will change
#   to that of the icon it is assigned.
#
#   Icon filenames are the custom graphics  that are used  to show the mouse on
#   the screen.   These 24x24 graphics are stored in the Graphics\Icons folder.
#
#   The MOUSE_DEFAULT value holds the handle of the regular/default mouse as it
#   is seen throughout the game.   As the mouse typically  keeps the same shape
#   throughout the game, this feature is rather under-used. But it is necessary
#   to assign a name nonetheless.
#
#   The MOUSE_ICON hash array  holds the custom handles for each icon  (and the
#   mouse icons) that are shown when the mouse is over an event.   It is fairly
#   straightforward and uses only a pair of values...  the handle and the icon.
#   First, enter the custom handle, then have it point to an Icon filename. The
#   one thing to remember is that you must also include the MOUSE_DEFAULT value
#   and assign it a custom icon as well.
#
#-------------------------------------------------------------------------------
#  
#   CALL VALUES FOR YOUR PROJECT
#
#   This system  is designed  to update  all mouse data automatically  as it is 
#   tied into the  Input class  and is processed through the Input.update calls
#   throughout the default system.
#
#   Only a few actual calls are necessary:
#
#       Mouse.click?  *  Mouse.dbclick?  *  Mouse.pos  *  Mouse.pos_set
#               Mouse.pos_x  *  Mouse.pos_y  *  Mouse.screen
#                      Mouse.screen_x  *  Mouse.screen_y
#
#
#   Mouse.click?(key)
#       This call determines whether a mouse button is currently being pressed.
#       If the button is being pressed, it returns TRUE. If not, returns FALSE.
#       It works in the same manner as the Input.press? & Input.trigger? calls.
#           The 'key' value passed into the call  defines which mouse button is
#           to be tested:  Left_Click, Right_Click or Middle_Click
#
#   Mouse.dbclick?(key)
#       This call  determines whether  a mouse button  has been quickly pressed
#       and released twice.   If the button was twice-clicked,  it returns TRUE
#       If not, it returns FALSE.
#           The 'key' value passed into the call  defines which mouse button is
#           to be tested:  Left_Click, Right_Click or Middle_Click
#
#   Mouse.pos
#       This call returns the mouse cursor's X and Y position (in pixels) based
#       on the game's screen.  Under normal conditions, this is a 640x480 area.
#           A passable value of 'false' allows this method to return a value of
#           'nil' if the mouse os outside the gaming window, otherwise it re-
#           turns a position of -1,-1.
#
#   Mouse.pos_set(x, y)
#       This call sets the mouse cursor's position specified by x and y.
#
#   Mouse.pos_x
#       This call returns  the mouse cursor's X position  (in pixels)  based on 
#       the game's screen. Under normal conditions, would be a value up to 640.
#
#   Mouse.pos_y
#       This call returns  the mouse cursor's Y position  (in pixels)  based on 
#       the game's screen. Under normal conditions, would be a value up to 480.
#
#   Mouse.screen
#       This call returns the mouse cursor's X and Y position (in pixels) based
#       on the entire window screen, regardless if it is within the game window
#       or not.  The returned value is based solely on the screen and the reso-
#       lution settings for your display.
#
#   Mouse.screen_x
#       This call returns  the mouse cursor's X position  (in pixels)  based on 
#       the entire window screen,  regardless if it's within the game window or
#       not.
#
#   Mouse.screen_y
#       This call returns  the mouse cursor's X position  (in pixels)  based on 
#       the entire window screen,  regardless if it's within the game window or
#       not.
#
#-------------------------------------------------------------------------------
#
#  CREDITS AND THANKS
#
#  Some routines within this script have been based on the work of Mr.Mo,
#  Lambchop, Behemoth and Near Fantastica.
#  
#===============================================================================  
  
  
  # Default Handle                    Default String
    MOUSE_DEFAULT                 =   "Default"

  # Mouse Array    Cursor Handle      Mouse Icon file
    MOUSE_ICON = { MOUSE_DEFAULT  =>  "Arrow",
                   "NPC"          =>  "Arrow",
                   "Boom"         =>  "Arrow",
                   "Monster"      =>  "Arrow"  }
                   
  # Left-Clicking Control---
  # 0 = single click action
  # 1 = double-click action
  MOUSE_LEFT_ACTION = 0
  
  # Right-Clicking Control--
  # 0 = Menu / 'B' pressed
  # 1 = Stop Movement
  MOUSE_RIGHT_ACTION = 0

  #  Movement range--
  #  Range in 'steps' the pathfinding 
  #  for NF Pathfinding version 2 beta
  #  High values & large maps causes lag
  PF_RANGE = 100

  
module Mouse
  #-------------------------------------------------------------------------
  # * Win32API calls
  #-------------------------------------------------------------------------
  @cursor_pos_get = Win32API.new('user32', 'GetCursorPos', 'p', 'i')
  @cursor_pos_set = Win32API.new('user32', 'SetCursorPos', 'ii', 'i')
  @cursor_show    = Win32API.new('user32', 'ShowCursor', 'L', 'i')
  @window_find    = Win32API.new('user32', 'FindWindowA', %w(p p), 'l')  
  @window_c_rect  = Win32API.new('user32', 'GetClientRect', %w(l p), 'i')
  @window_scr2cli = Win32API.new('user32', 'ScreenToClient', %w(l p), 'i')
  @readini        = Win32API.new('kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 'l') 
  @key            = Win32API.new("user32", "GetAsyncKeyState", 'i', 'i')
  #-------------------------------------------------------------------------
  # * Mouse Button Values
  #-------------------------------------------------------------------------
  Left_Click    = 1
  Right_Click   = 2
  Middle_Click  = 4
  MOUSE_BUTTONS = { Left_Click    => 1,
                    Right_Click   => 2,
                    Middle_Click  => 4 }
  MOUSE_REPEAT = MOUSE_BUTTONS.clone
  MOUSE_REPEAT.keys.each { |k| MOUSE_REPEAT[k] = [false, false, 10]}  
  #-------------------------------------------------------------------------
  # * Game Initialization Values
  #-------------------------------------------------------------------------
  @game_window = nil    # Set game handle to nil
  @cursor_show.call(0)  # Turn off system mouse
  @windows = []          # List of windows mouse is currently over
  @saved_window = nil    # Holds the last active window
  #-------------------------------------------------------------------------
  # * Click?
  #     button : button to check
  #-------------------------------------------------------------------------
  def Mouse.click?(button)
    MOUSE_REPEAT[button][1] >= 1
  end
  #-------------------------------------------------------------------------
  # * Double Clicked?
  #     button : button to check
  #-------------------------------------------------------------------------
  def Mouse.dbclick?(button)
    MOUSE_REPEAT[button][1] == 2
  end  
  #-------------------------------------------------------------------------
  # * Get Mouse Position
  #-------------------------------------------------------------------------
  def Mouse.pos(catch_anywhere = true)
    x, y = screen_to_client(screen_x, screen_y)
    width, height = client_size
    if catch_anywhere or (x >= 0 and y >= 0 and x < width and y < height)  
      return x, y
    else
      return -1, -1
    end    
  end
  #-------------------------------------------------------------------------
  # * Returns true if Mouse is over game screen
  #-------------------------------------------------------------------------
  def Mouse.on_screen?
    return (Mouse.pos(false) != [-1,-1])
  end
  #-------------------------------------------------------------------------
  # * Returns the game window's origin
  #-------------------------------------------------------------------------
  def Mouse.game_origin
    x,y = Mouse.pos
    return screen_x - x, screen_y - y
  end
  
  #-------------------------------------------------------------------------
  # * Set Mouse Position
  #     x      : new x-coordinate (0 to 640)
  #     y      : new y-coordinate (0 to 480)
  #-------------------------------------------------------------------------
  def Mouse.pos_set(x, y)
    x = [[x, 0].max, 640].min
    y = [[y, 0].max, 480].min
    ox, oy = Mouse.game_origin
    @cursor_pos_set.call(ox + x, oy + y)
  end
  #-------------------------------------------------------------------------
  # * Get Mouse X-Coordinate Position
  #-------------------------------------------------------------------------
  def Mouse.pos_x
    x, y = pos
    return x
  end
  #-------------------------------------------------------------------------
  # * Get Mouse Y-Coordinate Position
  #-------------------------------------------------------------------------
  def Mouse.pos_y
    x, y = pos
    return y
  end
  #-------------------------------------------------------------------------
  # * Get Mouse Screen Position
  #-------------------------------------------------------------------------
  def Mouse.screen
    pos = [0, 0].pack('ll')
    @cursor_pos_get.call(pos)
    return pos.unpack('ll')
  end  
  #-------------------------------------------------------------------------
  # * Get Mouse Screen X-Coordinate Position
  #-------------------------------------------------------------------------
  def Mouse.screen_x
    pos = [0, 0].pack('ll')
    @cursor_pos_get.call(pos)
    return pos.unpack('ll')[0]
  end
  #-------------------------------------------------------------------------
  # * Get Mouse Screen Y-Coordinate Position
  #-------------------------------------------------------------------------
  def Mouse.screen_y
    pos = [0, 0].pack('ll')
    @cursor_pos_get.call(pos)
    return pos.unpack('ll')[1]
  end
  
  def Mouse.window_add(win)
    return unless win.is_a?(Window_Base)
    @windows.push(win)
  end
  
  def Mouse.saved_window=(win)
    return unless win.is_a?(Window_Base)
    @saved_window = win
  end
  
  def Mouse.update_windows
    return if @windows.size == 0
    # Organize list of windows based on z-coord
    while @windows.size > 1
      if @windows[0].z < @windows[1].z
        @windows[1].active = false
        @windows.delete_at(1)
      else
        @windows[0].active = false
        @windows.delete_at(0)
      end
    end
    # Activate the window
    @windows[0].active = true
    # Save the window as the "current" window and deactivate the previous one
    if @windows[0] != @saved_window
      @saved_window.active = false unless (@saved_window.nil? or @saved_window.disposed?)
      @saved_window = @windows[0]
    end
    # Clear the array for next update
    @windows = []
  end
  #-------------------------------------------------------------------------
  #                           AUTOMATIC FUNCTIONS                          #
  #-------------------------------------------------------------------------
  #-------------------------------------------------------------------------
  # * Get the Game Window's width and height
  #-------------------------------------------------------------------------
  def Mouse.client_size
    rect = [0, 0, 0, 0].pack('l4')
    @window_c_rect.call(Mouse.hwnd, rect)
    right, bottom = rect.unpack('l4')[2..3]
    return right, bottom
  end  
  #-------------------------------------------------------------------------
  # * Get the game window handle (specific to game)
  #-------------------------------------------------------------------------
  def Mouse.hwnd
    if @game_window.nil?
      game_name = "\0" * 256
      @readini.call('Game','Title','',game_name,255,".\\Game.ini")
      game_name.delete!("\0")
      @game_window = @window_find.call('RGSS Player',game_name)
    end
    return @game_window
  end  
  #-------------------------------------------------------------------------  
  # * Convert game window coordinates from screen coordinates
  #-------------------------------------------------------------------------  
  def Mouse.screen_to_client(x, y)
    return nil unless x and y
    pos = [x, y].pack('ll')
    if @window_scr2cli.call(hwnd, pos) != 0
       return pos.unpack('ll')
     else
       return nil
    end
  end
  
  #-------------------------------------------------------------------------  
  # * Convert game window coordinates from screen coordinates
  #-------------------------------------------------------------------------  
  def Mouse.client_to_screen(x, y)
    x, y = screen_to_client(screen_x, screen_y)
    return x,y
    return nil unless x and y
    pos = [x, y].pack('ll')
    if @window_scr2cli.call(hwnd, pos) != 0
       return pos.unpack('ll')
     else
       return nil
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (Mouse version)
  #--------------------------------------------------------------------------
  def Mouse.update
    MOUSE_BUTTONS.keys.each do |key|
      temp = MOUSE_REPEAT[key][0]
      key_pres = @key.call(MOUSE_BUTTONS[key]) != 0
      key_trig = temp == key_pres ? 0 : (key_pres ? (MOUSE_REPEAT[key][2].between?(1, 9) ? 2 : 1) : -1)
      count = key_trig > 0 ? 0 : [MOUSE_REPEAT[key][2]+1, 20].min
      MOUSE_REPEAT[key] = [key_pres, key_trig, count]
    end
  end
  #-------------------------------------------------------------------------
  # * Visible?
  #-------------------------------------------------------------------------
  def Mouse.visible?(visible=true)
    if visible
      @cursor_show.call(-1)
    else
      @cursor_show.call(0)
    end
  end
end



#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles data surrounding the system. Backround music, etc.
#  is managed here as well. Refer to "$game_system" for the instance of 
#  this class.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :mouse_pf1                # Path Finding v1 detection bool
  attr_accessor :mouse_pf2                # Path Finding v2 detection bool
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias mouse_init initialize
  def initialize
    mouse_init
    @mouse_pf1 = nil
    @mouse_pf2 = nil
  end
end



#==============================================================================
# ** Sprite_Mouse
#------------------------------------------------------------------------------
#  This sprite is used to display the mouse.  It observes the Mouse module and
#  automatically changes mouse graphic conditions.
#==============================================================================

class Sprite_Mouse
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :icon
  attr_accessor :x
  attr_accessor :y
  attr_accessor :clicked
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @x            = 0
    @y            = 0
    @clicked    = nil
    @sprite       = Sprite.new
    @sprite.z     = 5000
    @draw         = false
    @events       = {}
    reset
  end
  #--------------------------------------------------------------------------
  # * Reset
  #--------------------------------------------------------------------------
  def reset
    @icon = RPG::Cache.icon(MOUSE_ICON[MOUSE_DEFAULT])
    @icon_name = MOUSE_ICON[MOUSE_DEFAULT]
    @sprite.bitmap.dispose if @sprite.bitmap != nil and @sprite.bitmap.disposed?
    @sprite.bitmap = @icon
    @draw = false
    # Updates the co-ordinates of the icon
    @x, @y = Mouse.pos
    @sprite.x = @x
    @sprite.y = @y
    @sprite.z = 99000
    @sprite.visible = true
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    Mouse.update
    # Updates the co-ordinates of the icon
    @x, @y = Mouse.pos
    return if @x == nil or @y == nil
    #Get Client Size
    width,height = Mouse.client_size
    @sprite.x = @x
    @sprite.y = @y
    #Check if needs to restart
    (@draw = (@x < 0 or @y < 0 or @x > width or @y > height)) if !@draw
    #Reset if need to reset
    reset if @draw and @x > 1 and @y > 1 and @x < width and @y < height
    #Show mouse if need to
    if (@x < 0 or @y < 0 or @x > width or @y > height) and @visible
      Mouse.visible?
    elsif (@x > 0 or @y > 0 or @x < width or @y < height) and !@visible
      Mouse.visible?(false)
    end
    #Return if Scene is not Scene_Map
    return if !$scene.is_a?(Scene_Map)
    #Check if the mouse is clicked
    mouse_pressed if Mouse.click?(Mouse::Left_Click) and !$game_temp.message_window_showing
    if MOUSE_RIGHT_ACTION == 1
      if $game_system.mouse_pf1
        $game_player.clear_path if Mouse.click?(Mouse::Right_Click)
      end
      if $game_system.mouse_pf2
        $path_finding.setup_depth(PF_RANGE)
        $path_finding.setup_player if Mouse.click?(Mouse::Right_Click)
      end
    end
    #Check for mouse over
    mouse_over_icon
  end
  #--------------------------------------------------------------------------
  # * Mouse Pressed
  #--------------------------------------------------------------------------
  def mouse_pressed(button_type = nil)
    @clicked = 1
    if Mouse.dbclick?(Mouse::Left_Click)
      @clicked = 2
    end
    # Routines called for Path Finding v1
    if $game_system.mouse_pf1
      # Turn to face regardless
      $game_player.find_facing(tile_x, tile_y)
      #If there is nothing than move
      return if !$game_map.passable?(tile_x, tile_y, 0, $game_player)
      $game_player.find_path(tile_x, tile_y)
    end
    # Routines called for Path Finding v2
    if $game_system.mouse_pf2
      $path_finding.setup_depth(PF_RANGE)
      $path_finding.setup_player
      $path_finding.add_paths_player(tile_x, tile_y, true)
      $path_finding.start_player      
    end
  end
  #--------------------------------------------------------------------------
  # * Mouseover Icon
  #--------------------------------------------------------------------------
  def mouse_over_icon
    object = get_object
    if object[0]
      event = @events[object[1].id]
      return if event == nil
      list = event.list
      return if list == nil
      #Check what the list is
      for key in MOUSE_ICON.keys
        next if !list.include?(key)
        next if @icon_name == MOUSE_ICON[key]
        @icon = RPG::Cache.icon(MOUSE_ICON[key])
        @icon_name = MOUSE_ICON[key]
        @sprite.bitmap.dispose if @sprite.bitmap != nil or @sprite.bitmap.disposed?
        @sprite.bitmap = @icon
      end
    elsif @icon_name != MOUSE_ICON[MOUSE_DEFAULT]
      @icon = RPG::Cache.icon(MOUSE_ICON[MOUSE_DEFAULT])
      @icon_name = MOUSE_ICON[MOUSE_DEFAULT]
      @sprite.bitmap.dispose if @sprite.bitmap != nil or @sprite.bitmap.disposed?
      @sprite.bitmap = @icon
    end
  end
  #--------------------------------------------------------------------------
  # * Get the current x-coordinate of the tile
  #--------------------------------------------------------------------------
  def tile_x
    return ((($game_map.display_x.to_f/4.0).floor + @x.to_f)/32.0).floor
  end
  #--------------------------------------------------------------------------
  # * Get the current y-coordinate of the tile
  #--------------------------------------------------------------------------
  def tile_y
    return ((($game_map.display_y.to_f/4.0).floor + @y.to_f)/32.0).floor
  end  
  #--------------------------------------------------------------------------
  # * Get Object
  #--------------------------------------------------------------------------
  def get_object
    for event in $game_map.events.values
      return [true,event] if event.x == tile_x and event.y == tile_y
    end
    return [false,nil]
  end  
  #--------------------------------------------------------------------------
  # * MOUSE Refresh(Event, List, Characterset Name
  #--------------------------------------------------------------------------
  def refresh(event, list)
    @events.delete(event.id)
    if event.list && event.list[0].code == 108
      icon = event.list[0].parameters 
    end
    @events[event.id] = Mouse_Event.new(event.id)
    @events[event.id].list = icon
  end
end



$mouse = Sprite_Mouse.new


#==============================================================================
# ** Mouse_Event
#------------------------------------------------------------------------------
#  This class deals with events. It adds new functionality between events and
#  the mouse system.  It's used within the Game_Map class.
#==============================================================================

class Mouse_Event
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :id
  attr_accessor :list
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(id)
    @id = id
    @list = nil
  end
end



#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
#  switching via condition determinants, and running parallel process events.
#  It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Event ID
  #--------------------------------------------------------------------------
  def id
    return @id
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  alias nf_game_event_refresh refresh
  def refresh
    nf_game_event_refresh
    $mouse.refresh(self, @list)
  end
end



#==============================================================================
# ** Input
#------------------------------------------------------------------------------
#   Adds new Mouse Input functions into a new class
#==============================================================================
module Input
  C.push(Input::Key['Mouse Left']) if !C.include?(Input::Key['Mouse Left'])
  B.push(Input::Key['Mouse Right']) if !B.include?(Input::Key['Mouse Right'])
end

class << Input
  
  #--------------------------------------------------------------------------
  # * Update old input calls
  #--------------------------------------------------------------------------
  alias old_update update unless $@
  def Input.update
    old_update
    $mouse.update
  end
end



#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This class deals with characters. It's used as a superclass for the
#  Game_Player and Game_Event classes.
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------  
  attr_accessor :facingpath               # direction faced if 1 tile away
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias mouse_init initialize
  def initialize
    mouse_init
    # Path Finding v1 Detection
    if defined?(find_path)
      $game_system.mouse_pf1 = true
    else
      if defined?(pf_passable?)
        $game_system.mouse_pf2 = true
      end
    end
  end  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias mouse_update update
  def update
    turn_facing if @facingpath != 0
    mouse_update
  end  
  #--------------------------------------------------------------------------
  # * Find Facing Direction
  #   Addition to Path Finding v 1
  #--------------------------------------------------------------------------  
  def find_facing(x,y)
    sx, sy = @x, @y      
    @facingpath = find_direction(sx,sy,x,y)
  end  
  #--------------------------------------------------------------------------
  # * Find Direction
  #   Addition to Path Finding v 1
  #--------------------------------------------------------------------------  
  def find_direction(sx,sy,ex,ey)
    ffx = sx - ex
    ffy = sy - ey
    facing = 0
    case ffx
    when 1 ; facing = 4
    when -1; facing = 6
    when 0
      case ffy
      when 1 ; facing = 8
      when -1; facing = 2
      end
    end
    return facing
  end  
  #--------------------------------------------------------------------------
  # * Turn Towards Object
  #   Addition to Path Finding v 1
  #--------------------------------------------------------------------------
  def turn_to(b)
    # Get difference in player coordinates
    sx = @x - b.x
    sy = @y - b.y
    # If coordinates are equal
    if sx == 0 and sy == 0
      return
    end
    # If horizontal distance is longer
    if sx.abs > sy.abs
      # Turn to the right or left towards player 
      sx > 0 ? turn_left : turn_right
    # If vertical distance is longer
    else
      # Turn up or down towards player
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # * Turn Facing Click
  #   Addition to Path Finding v 1
  #--------------------------------------------------------------------------  
  def turn_facing
    case @facingpath
    when 2; turn_down
    when 4; turn_left
    when 6; turn_right
    when 8; turn_up
    end
    # Turn off
    @facingpath = 0
  end  
  #--------------------------------------------------------------------------
  # * Run Path
  #   EDIT to Path Finding v 1
  #--------------------------------------------------------------------------
  def run_path
    return if moving?
    step = @map[@x,@y]
    if step == 1
      @map = nil
      @runpath = false
      turn_to(@object) if @object != nil and in_range?(self, @object, 1)
      return
    end
    dir = rand(2)
    case dir
    when 0
      move_right  if @map[@x+1, @y]   == step - 1 and step != 0
      move_down   if @map[@x,   @y+1] == step - 1 and step != 0
      move_left   if @map[@x-1, @y]   == step - 1 and step != 0
      move_up     if @map[@x,   @y-1] == step - 1 and step != 0
    when 1
      move_up     if @map[@x,   @y-1] == step - 1 and step != 0
      move_left   if @map[@x-1, @y]   == step - 1 and step != 0
      move_down   if @map[@x,   @y+1] == step - 1 and step != 0
      move_right  if @map[@x+1, @y]   == step - 1 and step != 0
    end
  end  
end

#==============================================================================
# ** Window_Selectable
#------------------------------------------------------------------------------
#  This window class contains cursor movement and scroll functions.
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * Initialize the mouse
  #--------------------------------------------------------------------------
  alias mouse_initialize initialize
  def initialize(x, y, width, height)
    mouse_initialize(x, y, width, height)
    @scroll_wait = 0
  end
  #--------------------------------------------------------------------------
  # * Update the mouse
  #--------------------------------------------------------------------------
  alias mouse_update update
  def update
    mouse_update
    mouse_operation if self.active
  end
  #--------------------------------------------------------------------------
  # * Perform mouse operations
  #--------------------------------------------------------------------------
  def mouse_operation
    return unless Mouse.on_screen?
    mx = Mouse.pos_x - (self.x - self.ox)
    my = Mouse.pos_y - (self.y - self.oy)
    
    width = self.width / @column_max
    height = 32
    #for index in 0...@item_max
    for index in self.top_row...(self.top_row + self.page_row_max)
      x = index % @column_max * width
      y = index / @column_max * 32
      if mx > x and mx < x + width and my > y and my < y + height
        mouse_cursor(index)
        return
      end
    end
    if (Mouse.pos_y < self.y and self.top_row != 0) or 
    (Mouse.pos_y > self.y + self.height and self.top_row + self.page_row_max < @item_max / @column_max)
      mouse_cursor(nil)
      return
    end
    
  end
  #--------------------------------------------------------------------------
  # * Track the position of the mouse cursor
  #--------------------------------------------------------------------------
=begin
 According to the way this is written, the window cursor will only scroll up/down by one
 when its current position is at the top or bottom of the window. If the location is not
 at either of those spots, it will jump. Thus, what I want is this:
1) If the mouse is located above the window (mouse_y < window_y) then @index = top_row - 1
2) "                     " below "        " (mouse_y > window_y) then @index = bottom_row + 1
3) If mouse is at a viable spot within the visible selections, immediately jump to it
=end
  def mouse_cursor(index)
    return if @index == index
    @scroll_wait -= 1 if @scroll_wait > 0
    #~ row1 = @index / @column_max
    #~ row2 = index / @column_max
    bottom = self.top_row + (self.page_row_max - 1)
    #~ print bottom if Input.trigger?(Input::SHIFT)
    #~ # Cursor is located above the top row item
    #~ if row1 == self.top_row and row2 < self.top_row
      #~ return if @scroll_wait > 0
      #~ @index = [@index - @column_max, 0].max
      #~ @scroll_wait = 10
      #~ # Cursor is located below the bottom row item
    #~ elsif row1 == bottom and row2 > bottom
      #~ return if @scroll_wait > 0
      #~ @index = [@index + @column_max, @item_max - 1].min
      #~ @scroll_wait = 10
    #~ else
      #~ @index = index
    #~ end
    if Mouse.pos_y < self.y and self.top_row != 0
      return if @scroll_wait > 0
      @index = self.top_row - @column_max
      @scroll_wait = 10
    elsif Mouse.pos_y > self.y + self.height and @index < @item_max - @column_max
      return if @scroll_wait > 0
      @index = bottom + @column_max
      @scroll_wait = 10
    else
      return if index == nil
      @index = index
      @scroll_wait = 0
    end
    $game_system.se_play($data_system.cursor_se)
    
  end
end

#==============================================================================
# ** Window_NameInput
#------------------------------------------------------------------------------
#  This window is used to select text characters on the input name screen.
#==============================================================================

class Window_NameInput < Window_Base
  #--------------------------------------------------------------------------
  # ● Update the position of the mouse
  #--------------------------------------------------------------------------
  alias mouse_update update
  def update
    mouse_update
    mouse_operation if self.active
  end
  #--------------------------------------------------------------------------
  # * Perform mouse operations
  #--------------------------------------------------------------------------
  def mouse_operation
    last_index = @index
    mx = Mouse.pos_x - (self.x - self.ox + 16)
    my = Mouse.pos_y - (self.y - self.oy + 16)
    width = 28
    height = 32
    for index in 0...180
      x = 4 + index / 5 / 9 * 152 + index % 5 * 28
      y = index / 5 % 9 * 32
      if mx > x and
          mx < x + width and
          my > y and
          my < y + height
        @index = index
        break
      end
    end
    x = 544
    y = 9 * 32
    width = 64
    if mx > x and
        mx < x + width and
        my > y and
        my < y + height
      @index = 180
    end
    $game_system.se_play($data_system.cursor_se) unless @index == index
  end
end



#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  This message window is used to display text.
#==============================================================================

class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # * Perform mouse operations
  #--------------------------------------------------------------------------
  def mouse_operation
    mx = Mouse.pos_x - (self.x - self.ox + 16)
    my = Mouse.pos_y - (self.y - self.oy + 16)
    x = 8
    width = 128 
    height = 32
    for index in 0...@item_max
      y = ($game_temp.choice_start + index) * 32
      if mx > x and mx < x + width and my > y and my < y + height
        mouse_cursor(index)
        break
      end
    end
  end
end

#==============================================================================
# ** Scene_File
#------------------------------------------------------------------------------
#  This is a superclass for the save screen and load screen.
#==============================================================================

class Scene_File
  #--------------------------------------------------------------------------
  # * Update the mouse
  #--------------------------------------------------------------------------
  alias mouse_update update
  def update
    mouse_update
    save = false
    mx, my = Mouse.pos
    x = 0
    width = (save ? 160 : 640)
    height = 104
    for index in 0...4
      y = 64 + index % 4 * 104
      if mx > x and
          mx < x + width and
          my > y and
          my < y + height
        break if @file_index == index
        @savefile_windows[@file_index].selected = false
        @file_index = index
        @savefile_windows[@file_index].selected = true
        $game_system.se_play($data_system.cursor_se)
        break
      end
    end
  end
end