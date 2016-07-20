#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  After defining each class, actual processing begins here.
#==============================================================================

# Error Logger: Creates a txt file that stores a backtrace on all game errors

ERROR_LOG_FILE = 'Error.log' # leave empty for no log
def mod_error(error)
  # load scripts
  scripts = load_data('Data/Scripts.rxdata')
  bt = error.backtrace.clone
  # change backtrace display to show script names
  bt.each_index {|i| bt[i] = bt[i].sub(/\d+/) {scripts[$&.to_i][1]} + "\n"}
  # new error message
  message = error.message + "\n" + bt.join('')
  # write to file if file defined
  if ERROR_LOG_FILE != ''
    File.open(ERROR_LOG_FILE, 'a') {|f| f.write("#{Time.now.to_s}:\n#{message}\n")}
  end
  return message
end

# No Deactivate: Game will keep running even when not in focus

if true #=====================================================================
  
module NoDeactivateDLL
  Start = Win32API.new("NoDeactivate", "Start", '', '')
  InFocus = Win32API.new("NoDeactivate", "InFocus", '', 'i')
end

module Graphics
  @inFocus = true
  def self.inFocus=(bool); @inFocus = bool; end
  def self.inFocus; @inFocus; end
end

module Input
  class << self
    alias update_again update
  end
  
  def self.update
    if NoDeactivateDLL::InFocus.call() == 1
      Graphics.inFocus = true
    else
      Graphics.inFocus = false
    end
    update_again
  end
end
NoDeactivateDLL::Start.call()

end     #=====================================================================

# Window Changing experiment
# Also defines a new way to do fullscreen: maximize without the borders. Overrides default ALT + ENTER too!
=begin
#=================================================
GetActiveWindow = Win32API.new('user32', 'GetActiveWindow', '', 'L')
SetWindowLong = Win32API.new('user32', 'SetWindowLong', 'LIL', 'L')
SetWindowPos  = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
GetSystemMetrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')

x = (GetSystemMetrics.call(0) - 640) / 2
y = (GetSystemMetrics.call(1) - 480) / 2
# Resize Border: 0x00040000
# No border: 0x10000000
# Normal: 0x14CA0000
#SetWindowLong.call(GetActiveWindow.call, -16, 0x14CB0000)#maximize button enabled
#SetWindowLong.call(GetActiveWindow.call, -16, 0x00040000)
SetWindowPos.call(GetActiveWindow.call, 0, x, y, 1920, 1080, 0x0060) #0


module Input
  GetActiveWindow = Win32API.new('user32', 'GetActiveWindow', '', 'L')
  SetWindowLong = Win32API.new('user32', 'SetWindowLong', 'LIL', 'L')
  SetWindowPos  = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
  GetSystemMetrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
  GetAsyncKeyState = Win32API.new('user32', 'GetAsyncKeyState', 'I', 'I')
  @fullscreenKeysReleased = true
  @fullscreen = false
  
  class << self
    alias get_fullscreen_keys update
    
    def update
      enterkey_state = GetAsyncKeyState.call(0x0D)
      if @fullscreenKeysReleased && Input.press?(Input::ALT) && enterkey_state != 0
        rw = GetSystemMetrics.call(0)
        rh = GetSystemMetrics.call(1)
        @fullscreen = !@fullscreen
        @fullscreenKeysReleased = false
        
        if @fullscreen
          SetWindowLong.call(GetActiveWindow.call, -16, 0x10000000)#maximize button enabled
          SetWindowPos.call(GetActiveWindow.call, 0, 0, 0, rw, rh, 0) #0
        else
          x = (rw - SCREEN_RESOLUTION[0]) / 2
          y = (rh - SCREEN_RESOLUTION[1]) / 2
          w = SCREEN_RESOLUTION[0] + (GetSystemMetrics.call(5) + GetSystemMetrics.call(45)) * 2
          h = SCREEN_RESOLUTION[1] + (GetSystemMetrics.call(6) + GetSystemMetrics.call(45)) * 2 + GetSystemMetrics.call(4)
          SetWindowLong.call(GetActiveWindow.call, -16, 0x14CA0000)
          SetWindowPos.call(GetActiveWindow.call, 0, x, y, w, h, 0x0020)
        end
      else
        @fullscreenKeysReleased = (!Input.press?(Input::ALT) || enterkey_state == 0)
      end
      get_fullscreen_keys
    end
  end
end
#===========================================================
=end




begin
  # Setting the FPS from 40 to 60
  Graphics.frame_rate = 60
  # Resize the screen (default to 640 by 480)
  Graphics.resize_screen(SCREEN_RESOLUTION[0], SCREEN_RESOLUTION[1]) # Values set in XPA Tilemap
  # Just an experiment: sets the game res to half the size (16x16)
  # Requires the above window experiment to be functioning
  #SetWindowPos.call(GetActiveWindow.call, 0, x, y, 320, 240, 0x0060)
  # Configure default font properties
  Font.default_color = Color.new(0, 0, 0) # Black
  Font.default_name = "AW_standard"       # Font file comes with game; be sure to install
  Font.default_size = 24                  # Exactly twice the size of the original games' font
  Font.default_outline = false            # Normally turned on for RGSS3, but it ruins this font; thus turned off
  # [ Load in Map files and initialize them ]
  # TODO

  # Load other data (such as CO objects)
  hash = {}
  $CO.each{|co| hash[co.to_s.sub(/CO_/, '')] = co.new }
  $CO = hash

  hash = {}
  $UNITS.each{|unit| hash[unit.to_s] = unit.new}
  $UNITS = hash
  # Prepare for transition
  Graphics.freeze
  # Make scene object (title screen)
  $scene = Scene_Title.new
  # Call main method as long as $scene is effective
  while $scene != nil
    $scene.main
  end
  # Fade out and close game
  Graphics.transition(20)
  exit
  
  # If error occurs mid-game
rescue Errno::ENOENT
  # Supplement Errno::ENOENT exception
  # If unable to open file, display message and end
  $!.message.sub!($!.message, mod_error($!))
  raise
  #filename = $!.message.sub("No such file or directory - ", "")
  #raise("Unable to find file #{filename}.")
rescue SyntaxError
  $!.message.sub!($!.message, mod_error($!))
  raise
rescue
  $!.message.sub!($!.message, mod_error($!))
  raise
end
