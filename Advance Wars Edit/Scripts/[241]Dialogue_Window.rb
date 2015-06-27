=begin
 Things to note
 
 Event command "Show Message" should tie in with this. Message window configs
 should also be handled inside it. Configurations include:
   CO face and expression
   Left or Right face position
   Top or Bottom of the screen
   Delay input (pauses message, then immediately continues without input)
   Maybe just delay in general (1/4 sec pause)
   Window border color (automatically changes based on CO, but who knows when
   you might need a specific color)
   
   Also, do not forget about choices and how they must be horizontally listed.
   
   These messages can occur at any moment, both on and off the battle. It also 
   needs to be constantly updated for the character-by-character, regardless of
   the scene. So placing an instance into a global var ($game_temp or system) 
   that can call this update consistently should work. Or overwrite
   Graphics#update to just call an update on the message window.

=end
class Dialogue_Window < Message_Window
  
  def initialize(on_bottom = true)
    @textbox = Sprite.new
    @textbox.bitmap = RPG::Cache.windowskin('textbox')
    @textbox.z = 2000
    # Set up the window object, but make it invisible
    super(0, -96, 500, 96)
    self.opacity = 0
    self.contents = Bitmap.new(500,96)
    # Create textbox
    
    @open = false
    @close = true
    # Create CO face sprite
    @face_sprite = Sprite.new
    @face_sprite.z = 2500
    @face_graphic = ""
    @expression = 0
    @shifting_phase = 0
    @face_sliding = false
    
    #
    @commands = []
    #
    if on_bottom
      self.x = 110 
      self.y = 480
      @face_sprite.x = 0
      @face_sprite.y = 480
      @textbox.y = 480
    else
      @face_sprite.x = 640 - 96
      @face_sprite.y = -96
      @textbox.y = -96
    end
    
    @on_bottom = on_bottom
  end
  
  alias set_y_for_textbox y=
  def y=(amt)
    set_y_for_textbox(amt)
    @textbox.y = amt
  end
  
  
  def set_window(co_name="", expression=0, on_bottom=true)
    # If window is not displayed right now
    if @state == MSG_IDLE
      # Move the window to the bottom?
      if @on_bottom != on_bottom
        @on_bottom = on_bottom
        self.x = @on_bottom ? 110 : 0
        self.y = @on_bottom ? 480 : -96
        @face_sprite.x = @on_bottom ? 0 : 640 - 96
        @face_sprite.y = @on_bottom ? 480 : -96
        @face_sprite.mirror = !@on_bottom
      end
      # If changing CO face or changing their expression
      if (co_name == "" && @expression != expression) || @face_graphic != co_name
        @face_graphic = "CO_" + co_name unless co_name == ""
        @expression = expression
        @face_sprite.bitmap = RPG::Cache.picture(@face_graphic)
        @face_sprite.src_rect = Rect.new(96 * expression, 700, 96, 96)
      end
    else
      @commands.push([0, co_name, expression, on_bottom])
    end
  end
  
  
  def update
    if @state == MSG_SWAP
      (@face_sliding ? slide_face : slide_window) if Graphics.frame_count % 2 == 0
    elsif @state != MSG_IDLE
      super
    end
  end
  
  
  def slide_window
    shift = case @shifting_phase
    when 6, 13 then 48
    when 5, 12 then 24
    when 4, 11 then 12
    when 3, 10 then 6
    when 2, 9  then 3
    when 1, 8  then 1
    end
    # Window is completely off screen
    if @shifting_phase == 7
      self.y = @on_bottom ? 480 : -96
      self.x = @on_bottom ? 110 : 0
      @face_sprite.x = @on_bottom ? 0 : 640-96
      # If closing the window
      if @close
        @shifting_phase = 6
        @open = false
        @state = MSG_IDLE
        return
      end
      # Change face graphic, even if still the same
      @face_sprite.bitmap = RPG::Cache.picture(@face_graphic)
      @face_sprite.src_rect = Rect.new(96 * @expression, 700, 96, 96)
      @face_sprite.mirror = !@on_bottom
    # Window is arriving from bottom
    elsif @on_bottom
      self.y -= shift
    # Window is arriving from top
    else
      self.y += shift
    end
    # Move the face sprite equally with the window
    @face_sprite.y = self.y
    # Decrease the phase counter
    @shifting_phase -= 1
    # Done shifting
    if @shifting_phase == 0
      @state = MSG_RUN
    end
  end
  
        
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def slide_face
    shift = case @shifting_phase
    when 6, 13 then 48
    when 5, 12 then 24
    when 4, 11 then 12
    when 3, 10 then 6
    when 2, 9  then 3
    when 1, 8  then 1
    end
    
    if @shifting_phase == 7
      @face_sprite.x = @on_bottom ? -96 : 640
      @face_sprite.bitmap = RPG::Cache.picture(@face_graphic)
      @face_sprite.src_rect = Rect.new(96 * @expression, 700, 96, 96)
      @face_sprite.mirror = !@on_bottom
    elsif @on_bottom && @shifting_phase > 7
      @face_sprite.x -= shift
    else
      @face_sprite.x += shift
    end
    # Decrease the phase counter
    @shifting_phase -= 1
    # Done shifting
    if @shifting_phase == 0
      @state = MSG_RUN
      @face_sliding = false
    end
  end
  
  
  
  #--------------------------------------------------------------------------
  # Check for when the window has no more commands to slide window off screen
  #--------------------------------------------------------------------------
  def run_message_window
    if !@open && @state == MSG_RUN
      @open = true
      @close = false
      @shifting_phase = 7
      @state = MSG_SWAP
    end
    super
    if @state == MSG_IDLE
      @close = true
      @shifting_phase = 13
      @state = MSG_SWAP
      @on_bottom = !@on_bottom
    end
  end
  
  
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def make_action(command)
    case command[0]
    when 0 # Face and window placement
      setup_window_display(command[1,3])
    end
    return super
  end
  #--------------------------------------------------------------------------
  # 
  #--------------------------------------------------------------------------
  def setup_window_display(parameters)
    # If changing the window's orientation
    if parameters[2] != @on_bottom
      @on_bottom = parameters[2]
      @shifting_phase = 13
      @state = MSG_SWAP
      slide_window
    end
    # If changing expression or face graphic
    if parameters[1] != @expression || parameters[0] != @face_graphic
      @expression = parameters[1]
      if parameters[0] != "" && parameters[0] != @face_graphic
        @face_graphic = "CO_" + parameters[0] 
        if @shifting_phase == 0
          @shifting_phase = 13
          @face_sliding = true
          @state = MSG_SWAP
          slide_face
        end
      else
        @face_sprite.src_rect = Rect.new(96 * @expression, 700, 96, 96)
      end
    end
  end
  
  
end