#==============================================================================
# Frame
#------------------------------------------------------------------------------
# Represents an advanced sprite class. It is lighter than a window and avoids
# usage of window specific additions that cannot be turned off. This class is
# abstract and should not be instantiated as such.
#==============================================================================

class Frame < Sprite
  
  # constants
  BORDER_COLOR = Color.new(255, 255, 255, 160)
  BACK_COLOR = Color.new(0, 0, 0, 160)
  # setting all accessible variables
  attr_accessor :active
  attr_reader   :width
  attr_reader   :height
  #----------------------------------------------------------------------------
  # Initialization.
  #  x             - x coordinate
  #  y             - y coordinate
  #  width         - width of the sprite
  #  height        - height of the sprite
  #----------------------------------------------------------------------------
  def initialize(x, y, width, height)
    # create the actual sprite
    super()
    # set dimensions
    @width = width
    @height = height
    # create background sprite
    create_background_sprite
    # set position
    self.x, self.y, self.z = x, y, 1000
    # store variables
    @active = true
  end
  #----------------------------------------------------------------------------
  # Creates a background sprite.
  #----------------------------------------------------------------------------
  def create_background_sprite
    # create background sprite
    @background = Sprite.new
    create_background_bitmap
  end
  #----------------------------------------------------------------------------
  # Creates the background bitmap.
  #----------------------------------------------------------------------------
  def create_background_bitmap
    @background.bitmap = Bitmap.new(@width, @height)
    @background.bitmap.fill_rect(0, 0, @width, @height, BORDER_COLOR)
    @background.bitmap.fill_rect(1, 1, @width - 2, @height - 2, BACK_COLOR)
  end
  #----------------------------------------------------------------------------
  # Updates the background sprite.
  #----------------------------------------------------------------------------
  def update_background
    @background.x, @background.y, @background.z = self.x, self.y, self.z - 1
  end
  #----------------------------------------------------------------------------
  # Changes the sprite width.
  #  value - new width
  #----------------------------------------------------------------------------
  def width=(value)
    # if width had changed
    if @width != value
      # delete old bitmap
      @background.bitmap.dispose if @background.bitmap != nil
      @width = value
      # create new background bitmap
      create_background_bitmap
    end
  end
  #----------------------------------------------------------------------------
  # Changes the sprite height.
  #  value - new height
  #----------------------------------------------------------------------------
  def height=(value)
    # if width had changed
    if @height != value
      # delete old bitmap
      @background.bitmap.dispose if @background.bitmap != nil
      @height = value
      # create new background bitmap
      create_background_bitmap
    end
  end
  #----------------------------------------------------------------------------
  # Changes sprite x.
  #  value - new x coordinate
  #----------------------------------------------------------------------------
  def x=(value)
    super
    update_background
  end
  #----------------------------------------------------------------------------
  # Changes sprite y.
  #  value - new y coordinate
  #----------------------------------------------------------------------------
  def y=(value)
    super
    update_background
  end
  #----------------------------------------------------------------------------
  # Changes sprite z.
  #  value - new z coordinate
  #----------------------------------------------------------------------------
  def z=(value)
    super
    update_background
  end
  #----------------------------------------------------------------------------
  # Refreshes the display. Abstract method.
  #----------------------------------------------------------------------------
  def refresh
  end
  #----------------------------------------------------------------------------
  # Disposes the additional background sprite.
  #----------------------------------------------------------------------------
  def dispose
    if @background.bitmap != nil
      @background.bitmap.dispose
      @background.bitmap = nil
    end
    @background.dispose
    super
  end
  
end

#==============================================================================
# Frame_Text
#------------------------------------------------------------------------------
# Handles basic user input from the keyboard for text related entries. This
# class is abstract and should not be instantiated as such.
#==============================================================================

class Frame_Text < Frame
  
  # constants
  CURSOR_COLOR = Color.new(255, 255, 255)
  # setting all accessible variables
  attr_reader :text
  attr_reader :password_char
  #----------------------------------------------------------------------------
  # Initialization.
  #  x             - x coordinate
  #  y             - y coordinate
  #  width         - width of the sprite
  #  height        - height of the sprite
  #  caption       - title text displayed
  #  text          - default text entered
  #  password_char - password character used to hide text (no hiding if empty)
  #----------------------------------------------------------------------------
  def initialize(x, y, width, height, text = '', password_char = '')
    # store variables
    @frame = 0
    @text = text
    @password_char = password_char
    # set cursor position at the end
    @cursor_position = text.scan(/./m).size
    # maximum text length
    self.max_length = RMXOS::Options::CHATINPUT_MAX_LENGTH
    # create the actual sprite
    super(x, y, width, height)
    # filter for input, allows all printable characters
    @input_filter = //
  end
  #----------------------------------------------------------------------------
  # Changes sprite x.
  #  value - new x coordinate
  #----------------------------------------------------------------------------
  def x=(value)
    super
    update_cursor
  end
  #----------------------------------------------------------------------------
  # Changes sprite y.
  #  value - new y coordinate
  #----------------------------------------------------------------------------
  def y=(value)
    super
    update_cursor
  end
  #----------------------------------------------------------------------------
  # Changes sprite z.
  #  value - new z coordinate
  #----------------------------------------------------------------------------
  def z=(value)
    super
    update_cursor
  end
  #----------------------------------------------------------------------------
  # Sets displayed text. Refreshes the display immediately.
  #  new_text - new text to be displayed
  #----------------------------------------------------------------------------
  def text=(new_text)
    @text = new_text
    refresh
    update_cursor
  end
  #----------------------------------------------------------------------------
  # Sets password character. Refreshes the display immediately.
  #  new_password_char - new password character to be used
  #----------------------------------------------------------------------------
  def password_char=(new_password_char)
    @password_char = new_password_char
    refresh
    update_cursor
  end
  #----------------------------------------------------------------------------
  # Changes maximum length of allowed text and truncates text if too long.
  #  new_max_length - new_max_length
  #----------------------------------------------------------------------------
  def max_length=(new_max_length)
    @max_length = new_max_length
    chars = @text.scan(/./m)
    @text = chars[0, @max_length].join if chars.size > @max_length
    self.cursor_move_to_end if @cursor_position > chars.size
  end
  #----------------------------------------------------------------------------
  # Gets the text that should be displayed. This method is needed so when using
  # a password character the original text can stay unchanged while it's
  # actually being displayed in password characters.
  # Returns: The text that should be displayed.
  #----------------------------------------------------------------------------
  def get_display_text
    return (@password_char == '' ? @text : @text.gsub(/./m) {@password_char})
  end
  #----------------------------------------------------------------------------
  # Moves the cursor to the left if possible.
  #----------------------------------------------------------------------------
  def cursor_move_left
    @cursor_position -= 1 if self.cursor_can_move_left?
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Moves the cursor to the right if possible.
  #----------------------------------------------------------------------------
  def cursor_move_right
    @cursor_position += 1 if self.cursor_can_move_right?
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Moves the cursor to the left end of a word.
  #----------------------------------------------------------------------------
  def cursor_move_left_word
    chars = @text.scan(/./m)
    # skip all whitespaces first
    while @cursor_position > 0 && chars[@cursor_position - 1] == ' '
      @cursor_position -= 1
    end
    # skip all non-whitespaces
    while @cursor_position > 0 && chars[@cursor_position - 1] != ' '
      @cursor_position -= 1
    end
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Moves the cursor to the right end of a word.
  #----------------------------------------------------------------------------
  def cursor_move_right_word
    chars = @text.scan(/./m)
    # skip all non-whitespaces first
    while @cursor_position < chars.size && chars[@cursor_position] != ' '
      @cursor_position += 1
    end
    # skip all whitespaces
    while @cursor_position < chars.size && chars[@cursor_position] == ' '
      @cursor_position += 1
    end
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Moves the cursor to the beginning.
  #----------------------------------------------------------------------------
  def cursor_move_to_beginning
    @cursor_position = 0
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Moves the cursor to the end.
  #----------------------------------------------------------------------------
  def cursor_move_to_end
    @cursor_position = @text.scan(/./m).size
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Checks if the cursor can move further left.
  # Returns: True of false.
  #----------------------------------------------------------------------------
  def cursor_can_move_left?
    return (@cursor_position > 0)
  end
  #----------------------------------------------------------------------------
  # Checks if the cursor can move further right.
  # Returns: True of false.
  #----------------------------------------------------------------------------
  def cursor_can_move_right?
    return (@cursor_position < @text.scan(/./m).size)
  end
  #----------------------------------------------------------------------------
  # Deletes the character left of the cursor if there is one.
  #  count - how many characters should be deleted
  #----------------------------------------------------------------------------
  def delete_left(count = 1)
    if self.cursor_can_move_left?
      # limiting character count
      count = @cursor_position if count > @cursor_position
      # split text at cursor with one character removed left from the cursor
      chars = @text.scan(/./m)
      left = (@cursor_position > count ? chars[0, @cursor_position - count] : [])
      if @cursor_position < chars.size
        right = chars[@cursor_position, chars.size - @cursor_position]
      else
        right = []
      end
      # set cursor at right position
      @cursor_position -= count
      # put together the split halves
      self.text = (left + right).join
      self.reset_cursor_blinking
    end
  end
  #----------------------------------------------------------------------------
  # Deletes the character right of the cursor if there is one.
  #  count - how many characters should be deleted
  #----------------------------------------------------------------------------
  def delete_right(count = 1)
    if self.cursor_can_move_right?
      # limiting character count
      chars = @text.scan(/./m)
      if count > chars.size - @cursor_position
        count = chars.size - @cursor_position
      end
      # moving cursor to the right
      @cursor_position += count
      # deleting everything left from cursor
      self.delete_left(count)
      self.reset_cursor_blinking
    end
  end
  #----------------------------------------------------------------------------
  # Deletes the word left of the cursor.
  #----------------------------------------------------------------------------
  def delete_left_word
    chars = @text.scan(/./m)
    position = @cursor_position
    # skip all whitespaces first
    while position > 0 && chars[position - 1] == ' '
      position -= 1
    end
    # skip all non-whitespaces
    while position > 0 && chars[position - 1] != ' '
      position -= 1
    end
    delete_left(@cursor_position - position) if @cursor_position > position
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Deletes the word right of the cursor.
  #----------------------------------------------------------------------------
  def delete_right_word
    chars = @text.scan(/./m)
    position = @cursor_position
    # skip all non-whitespaces first
    while position < chars.size && chars[position] != ' '
      position += 1
    end
    # skip all whitespaces
    while position < chars.size && chars[position] == ' '
      position += 1
    end
    delete_right(position - @cursor_position) if position > @cursor_position
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Inserts a character into the text right from the current cursor position
  # and moves the cursor positions.
  #  text - text that will be inserted into the current text
  #----------------------------------------------------------------------------
  def insert(text)
    chars = @text.scan(/./m)
    return if chars.size >= @max_length
    # limiting characters
    new_chars = text.scan(/./m)
    if chars.size + new_chars.size > @max_length
      new_chars = new_chars[0, @max_length - chars.size]
    end
    # it's possible that text contains tab characters which are forbidden
    while new_chars.include?("\t")
      new_chars.delete("\t")
    end
    return if new_chars.size == 0
    # split text at cursor position
    left = (@cursor_position > 0 ? chars[0, @cursor_position] : [])
    if @cursor_position < chars.size
      right = chars[@cursor_position, chars.size - @cursor_position]
    else
      right = []
    end
    # move cursor
    @cursor_position += new_chars.size
    # put together the split halves with the new text inbetween
    self.text = (left + new_chars + right).join
    self.reset_cursor_blinking
  end
  #----------------------------------------------------------------------------
  # Resets cursor blinking.
  #----------------------------------------------------------------------------
  def reset_cursor_blinking
    @frame = 0
  end
  #----------------------------------------------------------------------------
  # Shows/hides the cursor when activating/deactivating the window.
  #  value - true or false
  #----------------------------------------------------------------------------
  def active=(value)
    super
    self.reset_cursor_blinking
    update_cursor
  end
  #----------------------------------------------------------------------------
  # Updates the window behavior.
  #----------------------------------------------------------------------------
  def update
    super
    # blinking period of 1 second
    @frame = (@frame + 1) % RMXOS::Data::CursorBlinkPeriod
    update_input
    update_cursor
  end
  #----------------------------------------------------------------------------
  # Updates user input (moving cursor, deleting characters).
  # Returns: Whether to stop updating or not.
  #----------------------------------------------------------------------------
  def update_input
    # left key moves the cursor to the left
    if Input.repeat?(Input::LEFT)
      if Input.press?(Input::CTRL)
        self.cursor_move_left_word
      else
        self.cursor_move_left
      end
      return true
    end
    # right key moves the cursor to the left
    if Input.repeat?(Input::RIGHT)
      if Input.press?(Input::CTRL)
        self.cursor_move_right_word
      else
        self.cursor_move_right
      end
      return true
    end
    # home moves to the beginning
    if Input.trigger?(Input::Key['Home'])
      self.cursor_move_to_beginning
      return true
    end
    # end moves to the end
    if Input.trigger?(Input::Key['End'])
      self.cursor_move_to_end
      return true
    end
    # backspace deletes to the left
    if Input.repeat?(Input::Key['Backspace'])
      if Input.press?(Input::CTRL)
        self.delete_left_word
      else
        self.delete_left
      end
      return true
    end
    # backspace deletes to the right
    if Input.repeat?(Input::Key['Delete'])
      if Input.press?(Input::CTRL)
        self.delete_right_word
      else
        self.delete_right
      end
      return true
    end
    # get text
    text = Input.get_input_string
    # put text through input filter
    text.gsub!(@input_filter) {''}
    # if text is not empty
    if text != ''
      # insert it in the text
      self.insert(text)
      return true
    end
    return false
  end
  #----------------------------------------------------------------------------
  # Gets the x offset of the cursor.
  # Returns: X offset for the cursor.
  #----------------------------------------------------------------------------
  def cursor_x
    # x is "0" if cursor position at 0
    return -self.src_rect.x if !self.cursor_can_move_left?
    # find cursor position from text left from it
    display_text = get_display_text.scan(/./m)[0, @cursor_position].join
    return self.bitmap.text_size(display_text).width - self.src_rect.x
  end
  #----------------------------------------------------------------------------
  # Gets the y offset of the cursor.
  # Returns: Y offset for the cursor.
  #----------------------------------------------------------------------------
  def cursor_y
    return 2
  end
  #----------------------------------------------------------------------------
  # Gets the height of the cursor.
  # Returns: Height for the cursor.
  #----------------------------------------------------------------------------
  def cursor_height
    return 28
  end
  #----------------------------------------------------------------------------
  # Updates the cursor display.
  #----------------------------------------------------------------------------
  def update_cursor
    # if not active or blinking timer has exceeded value
    if !self.active || @frame >= RMXOS::Data::CursorBlinkPeriod / 2
      # if cursor exists
      if @cursor != nil
        # delete cursor
        @cursor.dispose
        @cursor = nil
      end
    else
      # if cursor does not exist
      @cursor = Sprite.new if @cursor == nil
      if @cursor.bitmap != nil && @cursor.bitmap.height != cursor_height
        @cursor.bitmap.dispose
        @cursor.bitmap = nil
      end
      if @cursor.bitmap == nil
        # create bitmap
        @cursor.bitmap = Bitmap.new(1, cursor_height)
        @cursor.bitmap.fill_rect(0, 0, 1, cursor_height, CURSOR_COLOR)
      end
      # position the cursor
      @cursor.x, @cursor.y = self.x + cursor_x, self.y + cursor_y
      @cursor.z = self.z + 1
    end
  end
  #----------------------------------------------------------------------------
  # Disposes the additional cursor sprite.
  #----------------------------------------------------------------------------
  def dispose
    if @cursor != nil
      @cursor.bitmap.dispose if @cursor.bitmap != nil
      @cursor.dispose
      @cursor = nil
    end
    super
  end
  
end

#==============================================================================
# Frame_Caption
#------------------------------------------------------------------------------
# Displays a text entry window with a caption. It allows the entry of usernames
# and passwords with a limited characterset of alphanumeric characters
# inluding "-" (minus) and "_" (underscore).
#==============================================================================

class Frame_Caption < Frame_Text
  
  #----------------------------------------------------------------------------
  # Initialization.
  #  x             - x coordinate
  #  y             - y coordinate
  #  width         - width of the window
  #  caption       - title text displayed
  #  text          - default text entered
  #  password_char - password character used to hide text (no hiding if empty)
  #----------------------------------------------------------------------------
  def initialize(x, y, width, caption, text = '', password_char = '')
    # create the actual window
    super(x, y, width, 32, text, password_char)
    # store variables
    @caption = caption
    # change max length
    self.max_length = RMXOS::Options::USERPASS_MAX_LENGTH
    # create display
    self.bitmap = Bitmap.new(@width, @height)
    # filter for input, allows all characters except white-space and apostrophe
    @input_filter = /([^\S])/
    refresh
  end
  #----------------------------------------------------------------------------
  # Refreshes the display.
  #----------------------------------------------------------------------------
  def refresh
    self.bitmap.clear
    # draw caption
    self.bitmap.draw_text(4, 0, 160, 32, @caption, 2)
    # draw text
    self.bitmap.draw_text(172, 0, @width - 8 - 168, 32, get_display_text)
  end
  #----------------------------------------------------------------------------
  # Gets the x offset of the cursor.
  # Returns: X offset for the cursor.
  #----------------------------------------------------------------------------
  def cursor_x
    return (super + 172)
  end
  
end

#==============================================================================
# Frame_ChatInput
#------------------------------------------------------------------------------
# Allows the entry of text for chatting and includes sending history.
#==============================================================================

class Frame_ChatInput < Frame_Text
  
  #----------------------------------------------------------------------------
  # Initialization.
  #----------------------------------------------------------------------------
  def initialize
    # create the actual window
    h = RMXOS::Data::ChatFontHeight
    super(0, RMXOS::Data::SCREEN_HEIGHT - h, RMXOS::Options::CHATINPUT_WIDTH, h)
    self.z = 10000
    @log_index = $game_temp.chat_logs.size
    self.active = false
    # create display
    self.bitmap = Bitmap.new(1, 1)
    refresh
  end
  #----------------------------------------------------------------------------
  # Refreshes the display.
  #----------------------------------------------------------------------------
  def refresh
    width = self.bitmap.text_size(@text).width + 8
    self.bitmap.dispose
    # create new bitmap
    x = self.src_rect.x
    self.bitmap = Bitmap.new(width + 4, @height)
    self.bitmap.font.size = RMXOS::Data::ChatFontHeight
    self.src_rect.x = x
    self.src_rect.width = @width
    # if using Tons of Add-ons that has Simple Shaded Text
    if $tons_version != nil && $tons_version >= 1.6
      # draw text
      self.bitmap.draw_text_shaded_later(2, -1, width - 4,
          RMXOS::Data::ChatFontHeight, @text)
    else
      # draw text
      self.bitmap.draw_text(2, -1, width - 4,
          RMXOS::Data::ChatFontHeight, @text)
    end
  end
  #----------------------------------------------------------------------------
  # Gets the x offset of the cursor.
  # Returns: X offset for the cursor.
  #----------------------------------------------------------------------------
  def cursor_x
    return (super + 2)
  end
  #----------------------------------------------------------------------------
  # Gets the height of the cursor.
  # Returns: Height for the cursor.
  #----------------------------------------------------------------------------
  def cursor_height
    return (RMXOS::Data::ChatFontHeight - 4)
  end
  #----------------------------------------------------------------------------
  # Updates user input (moving cursor, deleting characters).
  # Returns: Whether to stop updating or not.
  #----------------------------------------------------------------------------
  def update_input
    # abort if not active
    return false if !self.active
    # if holding CTRL
    if Input.press?(Input::CTRL)
      # if pressed UP
      if Input.repeat?(Input::UP)
        # if not at beginning of history
        if @log_index > 0
          @log_index -= 1
          # get current entry
          self.text = $game_temp.chat_logs[@log_index].clone
          self.cursor_move_to_end
        end
        return true
      # if pressed DOWN
      elsif Input.repeat?(Input::DOWN)
        # if there are still logs in the history
        if @log_index < $game_temp.chat_logs.size
          @log_index += 1
          # get current entry
          if @log_index < $game_temp.chat_logs.size
            self.text = $game_temp.chat_logs[@log_index].clone
          else
            self.text = ''
          end
          self.cursor_move_to_end
        end
        return true
      end
    end
    # if pressed enter
    if Input.repeat?(Input::Key['Enter'])
      # if any text entered
      if @text.size > 0
=begin
        $game_system.se_play($data_system.decision_se)
        # if not a special command
        if !$network.check_chat_commands(@text)
          # send this text per chat
          $network.command_chat(@text)
        end
=end
        # save this message in chat log
        $game_temp.chat_logs.push(@text)
        if $game_temp.chat_logs.size > RMXOS::Data::ChatLogSize
          $game_temp.chat_logs.shift
        end
        # reset
        @log_index = $game_temp.chat_logs.size
        self.text = ''
        self.cursor_move_to_beginning
      end
      return true
    end
    # call superclass method
    return super
  end
  #----------------------------------------------------------------------------
  # Updates the cursor display.
  #----------------------------------------------------------------------------
  def update_cursor
    x = cursor_x
    if x < 2
      self.src_rect.x += x - 2
    elsif x >= @width - 2
      self.src_rect.x += x - (@width - 2) + 1
    end
    super
  end
  
end

#==============================================================================
# Frame_Chat
#------------------------------------------------------------------------------
# Displays a chat log.
#==============================================================================

class Frame_Chat < Frame
  
  #----------------------------------------------------------------------------
  # Initialization.
  #----------------------------------------------------------------------------
  def initialize
    # create the actual window
    height = RMXOS::Options::CHATBOX_LINES * RMXOS::Data::ChatFontHeight
    super(0, RMXOS::Data::SCREEN_HEIGHT - height - RMXOS::Data::ChatFontHeight,
        RMXOS::Options::CHATBOX_WIDTH, height)
    self.z = 10000
    self.active = false
    # create display
    refresh
    if self.bitmap != nil && self.bitmap.height > @height
      self.src_rect.y = self.bitmap.height - @height
    end
  end
  #----------------------------------------------------------------------------
  # Refreshes the display.
  #----------------------------------------------------------------------------
  def refresh
    if self.bitmap != nil
      # remove old bitmap
      self.bitmap.dispose
      self.bitmap = nil
    end
    # abort if no messages
    return if $game_temp.chat_messages.size == 0
    # create new bitmap
    h = $game_temp.chat_messages.size * RMXOS::Data::ChatFontHeight
    self.bitmap = Bitmap.new(@width, h)
    self.bitmap.font.size = RMXOS::Data::ChatFontHeight
    self.src_rect.height = @height
    self.draw_messages
  end
  #----------------------------------------------------------------------------
  # Refreshes part of the display.
  #----------------------------------------------------------------------------
  def refresh_chat
    msgbox_p "Refresh chat"
    new_lines = $game_temp.chat_refresh
    $game_temp.chat_refresh = false
    # abort if no messages
    return if $game_temp.chat_messages.size == 0
    msgbox_p "Something to draw"
    # if no messages are being displayed yet
    if self.bitmap == nil
      # just draw them all
      refresh
      return
    end
    # store current display
    bitmap = self.bitmap
    h = $game_temp.chat_messages.size * RMXOS::Data::ChatFontHeight
    # scrolling down if at bottom
    if self.src_rect.y >= bitmap.height - @height && h > @height
      src_y = h - @height
    else
      src_y = self.src_rect.y
    end
    # creating a new bitmap
    self.bitmap = Bitmap.new(@width, h)
    self.bitmap.font.size = RMXOS::Data::ChatFontHeight
    self.src_rect.y = src_y
    self.src_rect.height = @height
    # y offset for drawing
    if bitmap.height == h
      y = new_lines * RMXOS::Data::ChatFontHeight
    else
      y = 0
    end
    self.bitmap.blt(0, 0, bitmap, Rect.new(0, y, @width, bitmap.height - y))
    # delete old bitmap
    bitmap.dispose
    # draw new messages
    self.draw_messages($game_temp.chat_messages.size - new_lines)
  end
  #----------------------------------------------------------------------------
  # Draws specific messages onto the display.
  #  start - starting message index
  #----------------------------------------------------------------------------
  def draw_messages(start = 0)
    h = RMXOS::Data::ChatFontHeight
    # if using Tons of Add-ons that has Simple Shaded Text
    if $tons_version != nil && $tons_version >= 1.6
      # skip shadow drawing
      (start...$game_temp.chat_messages.size).each {|i|
        # draw message
        self.bitmap.font.color = $game_temp.chat_messages[i].color
        self.bitmap.draw_text_shaded_later(2, i * h - 1, @width - 4, h,
            $game_temp.chat_messages[i].text)
      }
    else
      # draw normally
      (start...$game_temp.chat_messages.size).each {|i|
        # draw message
        self.bitmap.font.color = $game_temp.chat_messages[i].color
        self.bitmap.draw_text(2, i * h - 1, @width - 4, h,
            $game_temp.chat_messages[i].text)
      }
    end
  end
  #----------------------------------------------------------------------------
  # Updates the window.
  #----------------------------------------------------------------------------
  def update
    super
    refresh_chat if $game_temp.chat_refresh
    # if active and not holding CTRL
    if self.active && !Input.press?(Input::CTRL)
      # if pressed UP
      if Input.repeat?(Input::UP)
        # scroll up if possible
        self.src_rect.y -= RMXOS::Data::ChatFontHeight if self.src_rect.y > 0
        return true
      # if pressed DOWN
      elsif Input.repeat?(Input::DOWN)
        if self.bitmap != nil && self.src_rect.y < self.bitmap.height - @height
          self.src_rect.y += RMXOS::Data::ChatFontHeight
        end
        # scroll down if possible
        return true
      end
    end
  end
  
end