# A class that simulates dialogue by writing a character(s) each frame rather 
# than displaying them all at once
class Message_Window < Window_Base
  
  def initialize(x,y,width,height)
    super(x,y,width,height)
    self.contents = Bitmap.new(width, height)
    self.z = 2000
    # Holds all messages that need to be drawn and actions that must be performed
    @commands = []
    # String that the window is currently drawing
    @current_message = nil
    # The x,y coordinates (relative to the window) where to draw next character
    @draw_cursor = [0,10]
    # Create text continuation arrow
    @arrow_sprite = Sprite.new
    @arrow_sprite.bitmap = RPG::Cache.windowskin('textbox_arrow')
    @arrow_sprite.z = 3000
    @arrow_sprite.visible = false
    @arrow_frame = 0
    # Number of frames + 1 that passes before next char is drawn
    @speed = 2
    #
    @wait = 0
    @instant_text = false
    @auto_text_time = nil
    # Set initial state
    @state = MSG_IDLE
    # Adds this message instance into array of on-going messages
    $MESSAGES.push(self)
  end
  #--------------------------------------------------------------------------
	# 
	#--------------------------------------------------------------------------
  def add_text(string, time = nil)
    time.nil? ? @commands.push(string) : @commands.push([1,time],string)
    # Loaded with text, begin drawing
    @state = MSG_RUN
  end
  
  def update
    run_message_window if @state != MSG_WAIT
    update_message_arrow if @arrow_sprite.visible
    get_input
  end
  
  
  #--------------------------------------------------------------------------
	# 
	#--------------------------------------------------------------------------
  def run_message_window
    # Hold off on drawing until '@speed' number of frames have passed, or not
    # in waiting state
    if @wait > 0
      @wait -= 1
      return
    end
    # If commanded to start drawing
    if @state == MSG_RUN
      if @commands.size > 0
        # Clear window of previous text
        self.contents.clear
        # Get next message command
        command = @commands.shift
        if command.is_a?(Array)
          r = make_action(command)
          return if r
          command = @commands.shift
        end
        # Get next message to write
        @block = get_even_text(self.width, command)
        @current_message = @block.shift
        @draw_cursor = [0,10]
        @state = MSG_DRAW
      else
        # No more to draw, so back to waiting for new text to be added
        @state = MSG_IDLE
        @speed = 2
        return
      end
    end
    # If commanded to draw
    if @state == MSG_DRAW
      loop do
        if @current_message != ""
          # Get next character
          char = @current_message.slice!(0, 1)
          # Draw character
          self.contents.draw_text(@draw_cursor[0], @draw_cursor[1], self.width, 32, char)
          # Move cursor to the right
          @draw_cursor[0] += self.contents.text_size(char).width
          special_chars(char)
        elsif @block.size > 0
          # Give new message to write up and move cursor to next line
          @current_message = @block.shift
          @draw_cursor[0] = 0
          @draw_cursor[1] += self.contents.font.size + 12
          return
        else
          @instant_text = false
        end
        # Draw all characters if instant-mode activated
        break unless @instant_text
      end
      # Done drawing text
      if @current_message == "" && @block.size == 0
        # If automatic text
        if @auto_text_frame != nil
          @state = MSG_RUN
          @wait += @auto_text_frame
          @auto_text_frame = nil
        else
          # Wait for user input
          @state = MSG_WAIT
          # Active arrow sprite
          @arrow_sprite.x = @draw_cursor[0] + 12 + self.x
          @arrow_sprite.y = @draw_cursor[1] + 18 + self.y
          @arrow_sprite.visible = true
          @arrow_frame = 0
        end
        return
      end
      # Set wait counter for next drawn char
      @wait += @speed
    end
  end
  
  #--------------------------------------------------------------------------
	# 
	#--------------------------------------------------------------------------
  def make_action(command)
    case command[0]
    when 1
      @auto_text_frame = command[1]
      return false
    end
    return true
  end
  
  def special_chars(char)
    case char
    when ",", "!"
      @wait = @speed * 5
    when "."
      @wait = @speed * 10
    end
  end
  
  
  def update_message_arrow
    if @arrow_frame < 0
      @arrow_sprite.y += 1 if @arrow_frame > -5
      @arrow_frame = 20 if @arrow_frame == -20
    else
      @arrow_sprite.y -= 1 if @arrow_frame > 15
    end
    @arrow_frame -= 1
  end
  
  
  def get_input
    if Input.trigger?(Input::C)
      if @state == MSG_WAIT
        # Remove arrow
        @arrow_sprite.visible = false
        # Prepare for drawing again
        @state = MSG_RUN
      elsif @state == MSG_DRAW && @speed != 0
        @speed = 0
        @instant_text = true
      end
      
    end
    if Input.trigger?(Input::SHIFT)
      p @face_sprite.x, @face_sprite.y
    end
    
  end
  
  
  
  
end
  