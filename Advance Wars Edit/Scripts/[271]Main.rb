#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  After defining each class, actual processing begins here.
#==============================================================================

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

if false #=====================================================================
  
module NoDeactivateDLL
  Start = Win32API.new("NoDeactivate", "Start", '', '')
  InFocus = Win32API.new("NoDeactivate", "InFocus", '', 'i')
end

module Input
  class << self
    alias update_again update
  end
  
  def self.update
    update_again if NoDeactivateDLL::InFocus.call() == 1
  end
end
NoDeactivateDLL::Start.call()

end     #=====================================================================

begin
  Graphics.frame_rate = 60
  Graphics.resize_screen(SCREEN_RESOLUTION[0], SCREEN_RESOLUTION[1])
  
  Font.default_color = Color.new(0, 0, 0)
  Font.default_name = "AW_standard"
  Font.default_size = 24
  Font.default_outline = false
  # [ Load in Map files and initialize them ]
  
  # Prepare for transition
  Graphics.freeze
  # Make scene object (title screen)
  $scene = Scene_Title.new
  # Call main method as long as $scene is effective
  while $scene != nil
    $scene.main
  end
  # Fade out
  Graphics.transition(20)
  exit
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
