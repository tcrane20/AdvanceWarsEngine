# CREDITS TO BLIZZARD
#==============================================================================
# module Input
#==============================================================================

module Input
  
  #----------------------------------------------------------------------------
  # Simple ASCII table
  #----------------------------------------------------------------------------
  Key = {'A' => 65, 'B' => 66, 'C' => 67, 'D' => 68, 'E' => 69, 'F' => 70, 
         'G' => 71, 'H' => 72, 'I' => 73, 'J' => 74, 'K' => 75, 'L' => 76, 
         'M' => 77, 'N' => 78, 'O' => 79, 'P' => 80, 'Q' => 81, 'R' => 82, 
         'S' => 83, 'T' => 84, 'U' => 85, 'V' => 86, 'W' => 87, 'X' => 88, 
         'Y' => 89, 'Z' => 90,
         '0' => 48, '1' => 49, '2' => 50, '3' => 51, '4' => 52, '5' => 53,
         '6' => 54, '7' => 55, '8' => 56, '9' => 57,
         'NumberPad 0' => 45, 'NumberPad 1' => 35, 'NumberPad 2' => 40,
         'NumberPad 3' => 34, 'NumberPad 4' => 37, 'NumberPad 5' => 12,
         'NumberPad 6' => 39, 'NumberPad 7' => 36, 'NumberPad 8' => 38,
         'NumberPad 9' => 33,
         'F1' => 112, 'F2' => 113, 'F3' => 114, 'F4' => 115, 'F5' => 116,
         'F6' => 117, 'F7' => 118, 'F8' => 119, 'F9' => 120, 'F10' => 121,
         'F11' => 122, 'F12' => 123,
         ';' => 186, '=' => 187, ',' => 188, '-' => 189, '.' => 190, '/' => 220,
         '\\' => 191, '\'' => 222, '[' => 219, ']' => 221, '`' => 192,
         'Backspace' => 8, 'Tab' => 9, 'Enter' => 13, 'Shift' => 16,
         'Left Shift' => 160, 'Right Shift' => 161, 'Left Ctrl' => 162,
         'Right Ctrl' => 163, 'Left Alt' => 164, 'Right Alt' => 165, 
         'Ctrl' => 17, 'Alt' => 18, 'Esc' => 27, 'Space' => 32, 'Page Up' => 33,
         'Page Down' => 34, 'End' => 35, 'Home' => 36, 'Insert' => 45,
         'Delete' => 46, 'Arrow Left' => 37, 'Arrow Up' => 38,
         'Arrow Right' => 39, 'Arrow Down' => 40,
         'Mouse Left' => 1, 'Mouse Right' => 2, 'Mouse Middle' => 4,
         'Mouse 4' => 5, 'Mouse 5' => 6}
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# START Configuration
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  UP = [Key['Arrow Up']]
  LEFT = [Key['Arrow Left']]
  DOWN = [Key['Arrow Down']]
  RIGHT = [Key['Arrow Right']]
  A = [Key['Shift']]
  B = [Key['Esc'], Key['NumberPad 0'], Key['X']]
  C = [Key['Space'], Key['Enter'], Key['C'], Key['Mouse Left']]
  X = [Key['A']]
  Y = [Key['S']]
  Z = [Key['D']]
  L = [Key['Q'], Key['Page Down']]
  R = [Key['W'], Key['Page Up']]
  F5 = [Key['F5']]
  F6 = [Key['F6']]
  F7 = [Key['F7']]
  F8 = [Key['F8']]
  F9 = [Key['F9']]
  SHIFT = [Key['Shift']]
  CTRL = [Key['Ctrl']]
  ALT = [Key['Alt']]
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# END Configuration
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # All keys
  ALL_KEYS = (0...256).to_a
  # Win32 API calls
  GetKeyboardState = Win32API.new('user32','GetKeyboardState', 'P', 'I')
  GetKeyboardLayout = Win32API.new('user32', 'GetKeyboardLayout','L', 'L')
  MapVirtualKeyEx = Win32API.new('user32', 'MapVirtualKeyEx', 'IIL', 'I')
  ToUnicodeEx = Win32API.new('user32', 'ToUnicodeEx', 'LLPPILL', 'L')
  # some other constants
  DOWN_STATE_MASK = 0x80
  DEAD_KEY_MASK = 0x80000000
  # data
  @state = "\0" * 256
  @triggered = Array.new(256, false)
  @pressed = Array.new(256, false)
  @released = Array.new(256, false)
  @repeated = Array.new(256, 0)
  #----------------------------------------------------------------------------
  # update
  #  Updates input.
  #----------------------------------------------------------------------------
  def self.update
    # prevents usage with Blizz-ABS
    if $BlizzABS
      # error message
      raise 'Blizz-ABS was detected! Please turn off Custom Controls in Tons of Add-ons!'
    end
    # get current language layout
    @language_layout = GetKeyboardLayout.call(0)
    # get new keyboard state
    GetKeyboardState.call(@state)
    # for each key
    ALL_KEYS.each {|key|
      if XPACE
        byte = nil
        @state[key].bytes.each{|n| byte = n}
      else
        byte = @state[key]
      end
      # if pressed state
      if byte & DOWN_STATE_MASK == DOWN_STATE_MASK
        # not released anymore
        @released[key] = false
        # if not pressed yet
        if !@pressed[key]
          # pressed and triggered
          @pressed[key] = true
          @triggered[key] = true
        else
          # not triggered anymore
          @triggered[key] = false
        end
        # update of repeat counter
        @repeated[key] < 17 ? @repeated[key] += 1 : @repeated[key] = 15
      # not released yet
      elsif !@released[key]
        # if still pressed
        if @pressed[key]
          # not triggered, pressed or repeated, but released
          @triggered[key] = false
          @pressed[key] = false
          @repeated[key] = 0
          @released[key] = true
        end
      else
        # not released anymore
        @released[key] = false
      end
    }
  end
  #----------------------------------------------------------------------------
  # dir4
  #  4 direction check.
  #----------------------------------------------------------------------------
  def self.dir4
    return 2 if self.press?(DOWN)
    return 4 if self.press?(LEFT)
    return 6 if self.press?(RIGHT)
    return 8 if self.press?(UP)
    return 0
  end
  #----------------------------------------------------------------------------
  # dir8
  #  8 direction check.
  #----------------------------------------------------------------------------
  def self.dir8
    down = self.press?(DOWN)
    left = self.press?(LEFT)
    return 1 if down && left
    right = self.press?(RIGHT)
    return 3 if down && right
    up = self.press?(UP)
    return 7 if up && left
    return 9 if up && right
    return 2 if down
    return 4 if left
    return 6 if right
    return 8 if up
    return 0
  end
  #----------------------------------------------------------------------------
  # trigger?
  #  Test if key was triggered once.
  #----------------------------------------------------------------------------
  def self.trigger?(keys)
    keys = [keys] unless keys.is_a?(Array)
    return keys.any? {|key| @triggered[key]}
  end
  #----------------------------------------------------------------------------
  # press?
  #  Test if key is being pressed.
  #----------------------------------------------------------------------------
  def self.press?(keys)
    keys = [keys] unless keys.is_a?(Array)
    return keys.any? {|key| @pressed[key]}
  end
  #----------------------------------------------------------------------------
  # repeat?
  #  Test if key is being pressed for repeating.
  #----------------------------------------------------------------------------
  def self.repeat?(keys)
    keys = [keys] unless keys.is_a?(Array)
    return keys.any? {|key| @repeated[key] == 1 || @repeated[key] == 16}
  end
  #----------------------------------------------------------------------------
  # release?
  #  Test if key was released.
  #----------------------------------------------------------------------------
  def self.release?(keys)
    keys = [keys] unless keys.is_a?(Array)
    return keys.any? {|key| @released[key]}
  end
  #----------------------------------------------------------------------------
  # get_character
  #  vk - virtual key
  #  Gets the character from keyboard input using the input locale identifier
  #  (formerly called keyboard layout handles).
  #----------------------------------------------------------------------------
  def self.get_character(vk)
    # get corresponding character from virtual key
    c = MapVirtualKeyEx.call(vk, 2, @language_layout)
    # stop if character is non-printable and not a dead key
    return '' if c < 32 && (c & DEAD_KEY_MASK != DEAD_KEY_MASK)
    # get scan code
    vsc = MapVirtualKeyEx.call(vk, 0, @language_layout)
    # result string is never longer than 2 bytes (Unicode)
    result = "\0" * 2
    # get input string from Win32 API
    length = ToUnicodeEx.call(vk, vsc, @state, result, 2, 0, @language_layout)
    return (length == 0 ? '' : result)
  end
  #----------------------------------------------------------------------------
  # get_input_string
  #  Gets the string that was entered using the keyboard over the input locale
  #  identifier (formerly called keyboard layout handles).
  #----------------------------------------------------------------------------
  def self.get_input_string
    result = ''
    # check every key
    ALL_KEYS.each {|key|
        # if repeated
        if self.repeat?(key)
          # get character from keyboard state
          c = self.get_character(key)
          # add character if there is a character
          result += c if c != ''
        end}
    # empty if result is empty
    return '' if result == ''
    # convert string from Unicode to UTF-8
    return self.unicode_to_utf8(result)
  end
  #----------------------------------------------------------------------------
  # unicode_to_utf8
  #  string - string in Unicode format
  #  Converts a string from Unicode format to UTF-8 format as RGSS does not
  #  support Unicode.
  #----------------------------------------------------------------------------
  def self.unicode_to_utf8(string)
    result = ''
    string.unpack('S*').each {|c|
        # characters under 0x80 are 1 byte characters
        if c < 0x0080
          result += c.chr
        # other characters under 0x800 are 2 byte characters
        elsif c < 0x0800
          result += (0xC0 | (c >> 6)).chr
          result += (0x80 | (c & 0x3F)).chr
        # the rest are 3 byte characters
        else
          result += (0xE0 | (c >> 12)).chr
          result += (0x80 | ((c >> 12) & 0x3F)).chr
          result += (0x80 | (c & 0x3F)).chr
        end}
    return result
  end

end