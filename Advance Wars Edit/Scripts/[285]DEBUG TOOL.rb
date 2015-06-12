if $DEBUG || $TEST
  # Create a console object and redirect standard output to it.
  Win32API.new('kernel32', 'AllocConsole', 'V', 'L').call
  $stdout.reopen('CONOUT$')
  # Find the game title.
  ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
  title = "\0" * 256
  ini.call('Game', 'Title', '', title, 256, '.\\Game.ini')
  title.delete!("\0")
  # Set the game window as the top-most window.
  hwnd = Win32API.new('user32', 'FindWindowA', 'PP', 'L').call('RGSS Player', title)  
  Win32API.new('user32', 'SetForegroundWindow', 'L', 'L').call(hwnd)
  # Set the title of the console debug window'
  Win32API.new('kernel32','SetConsoleTitleA','P','S').call("#{title} :  Debug Console")
  # Draw the header, displaying current time.
  puts('=' * 75, Time.now, '=' * 75, "\n")
end

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Run-Time Script Caller
# Author: ForeverZer0
# Version: 1.0
# Date: 11.27.2010
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
# Introduction:
#
#  This script will allow you to open a small box while the game is running and
#  type script calls into, which will execute when the Enter button is pressed.
#
# Feature:
#
#  - Simple to use.
#  - Built in rescue to keep game from crashing if the script call is written
#    wrong, etc. Instead it shows the error and continues on.
#  - Did I mention you can make up script calls and change things at run-time.
#
# Instructions:
#
#  - Place script anywhere.
#  - Configure call button below (F7 by default)
#
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#===============================================================================
# ** ScriptEditor
#===============================================================================

class ScriptEditor
  
  CALL_BUTTON = Input::F7
  # Set the button to call the script box.
  
  def initialize
    # Get game window title from Game.ini
    ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
    @title = "\0" * 256
    ini.call('Game', 'Title', '', @title, 256, '.\\Game.ini')
    @title.delete!("\0")
    # Set game window to an instance variable, using the title we found.
    @main = Win32API.new('user32', 'FindWindowA', 'PP', 'L').call('RGSS Player', @title)
    # Set variables to call for creating showing, and destroying the window.
    @create_window = Win32API.new('user32','CreateWindowEx','lpplllllllll','l')
    @show_window = Win32API.new('user32','ShowWindow',%w(l l),'l')
    @destroy_window = Win32API.new('user32','DestroyWindow','p','l')
    # Set variables to get the window size, position, text, etc, etc.
    @window_text = Win32API.new('user32','GetWindowText',%w(n p n ),'l') 
    @metrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    @set_window_pos = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
    @window_rect = Win32API.new('user32','GetWindowRect',%w(l p),'i')
    # Define the coordinates to display the window.
    @x = (@metrics.call(0) - 576) / 2
    @y = (@metrics.call(1) - 22) / 2 
    # Updates the client area of the window.
    @update_window = Win32API.new('user32','UpdateWindow','p','i') 
    # Set a button that will register when button is pressed.
    @input = Win32API.new('user32','GetAsyncKeyState','i','i')
  end  
  
  def destroy_window
    # Disposes the created box for typing text, and sets variable to nil.
    @destroy_window.call(@script_window)
    @script_window = nil
  end
    
  def show_window
    # End method now if window is already there.
    if @script_window != nil
      return
    end
    # Create text box for adding text into, using window dimensions.
    @script_window = @create_window.call(768, 'Edit', '', 0x86000000, @x, @y, 576, 22, @main, 0, 0, 0)
    # Set the 'visibility' of the window.
    @show_window.call(@script_window, 1)
    # Begin the loop for the text box.
    start_script_update
  end   
  
  def start_script_update
    # Enter update loop.
    loop { 
      # Update the Graphics, and the window. Breaks when Enter button is pressed.
      Graphics.update
      @update_window.call(@script_window)
      break if @input.call(0x0D) & 0x01 == 1
    }
    # Get the text from the window.
    text = "\0" * 256
    @window_text.call(@script_window, text, 0x3E80)
    text.delete!("\0")
    # Evaluate the text, simply displaying a message if it throws an error.
    begin
      eval(text)
    rescue#'start_script_update'
      # Simply write the type of the error.
      message = $!.message.gsub("(eval):1:in `start_script_update'") { '' }
      print("#{$!.class}\r\n\r\n#{message}")
    end
    destroy_window
  end
end

if $DEBUG
  
  $editor = ScriptEditor.new
  # Create in instance of the class so it is ready to call.
  
  module Input
    
    class << self
      alias zer0_script_editor_upd update
    end
    
    def self.update
      # Alias the Input.update method to check if call button is pressed.
      $editor.show_window if self.trigger?(ScriptEditor::CALL_BUTTON)
      zer0_script_editor_upd
    end
  end
end