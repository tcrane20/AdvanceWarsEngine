#===============================================================================
# ~** [Legacy] High_Priority **~                                    
#-------------------------------------------------------------------------------
#  Author:      Legacy
#  Version:     1.0 - Edited
#  Build Date:  2011-03-05
#  Last Update: 2011-03-05
#===============================================================================


#==============================================================================
# ** Game_Priority
#------------------------------------------------------------------------------
#  This module contains the code to change the game's priority.
#==============================================================================

module Game_Priority
  #--------------------------------------------------------------------------
  # * Invariables
  #--------------------------------------------------------------------------
  Set_Priority = Win32API.new('kernel32', 'SetPriorityClass', ['p', 'i'], 'i')
  Elevated_Priority_Text = "ElevatedPriority=" # As shown in the Game.ini file
  Default_Elevated_Priority = true            # Default high priority?
  #--------------------------------------------------------------------------
  # * Name      : Elevated Priority
  #   Info      : Set the priority of the process
  #   Author    : Legacy
  #   Call Info : One arguement boolean value, set high priority true or false.
  #---------------------------------------------------------------------------                                 
  def self.elevated_priority=(value)
    @elevated_priority = value
    if @elevated_priority
      Set_Priority.call(-1, 0x00000080) # High 
    else
      Set_Priority.call(-1, 0x00000020) # Normal 
    end
  end
end



#==============================================================================
# ** Scene_ChoosePriority
#------------------------------------------------------------------------------
#  This class let's the player decide whether to have high priority.
#==============================================================================

class Scene_ChoosePriority
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def initialize
    # Make system object
    $game_system = Game_System.new
    $data_system        = load_data("Data/System.rxdata")
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Set a flag whether to quit processing or not
    @self_active = true
    # Make title graphic
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # Make the windows
    make_text_window
    make_selection_window
    # Transition the Graphics
    Graphics.transition(20)
    # Main Processing
    begin
      Graphics.update
      Input.update
      update
    end while @self_active
    # Freeze the graphics
    Graphics.freeze
    # Dispose of the windows
    dispose_windows
  end
  #--------------------------------------------------------------------------
  # * Make Text WIndow
  #--------------------------------------------------------------------------
  def make_text_window
    # Set variables for where to place the text window
    x = 160
    y = 128
    width = 320
    height = 128
    # Make the text window
    @text_window = Window_Base.new(x, y, width, height)
    # Make the bitmap (to draw the text on)
    @text_window.contents = Bitmap.new(width - 32, height - 32)
    # Find out if the default is high or normal priority
    default = Game_Priority::Default_Elevated_Priority ? 'High' : 'Normal'
    # Setup the text to show
    text = ["Would you like to play this game",
      "in elevated priority mode?",
      "(#{default} is recommended)"]
    # For every line of text, draw it on the window
    for i in 0...text.size
      line = text[i]
      @text_window.contents.draw_text(0, i * 32, width - 32, 32, line, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * Make Selection Window
  #--------------------------------------------------------------------------
  def make_selection_window
    options = ['High Priority', 'Normal Priority']
    @selection_window = Window_Command.new(160, options)
    @selection_window.x = 320 - @selection_window.width / 2
    @selection_window.y = @text_window.y + @text_window.height
  end
  #--------------------------------------------------------------------------
  # * Frame update
  #--------------------------------------------------------------------------
  def update
    # Update the important windows
    @selection_window.update
    # If the C input was triggered
    if Input.trigger?(Input::C)
      # Set this window to dispose
      @self_active = false
      # Read if the player selected high/normal priority
      high_priority = @selection_window.index == 0
      # Set the priority
      Game_Priority.elevated_priority = high_priority
      # Save the priority back to the game.ini file
      gameini = File.open('Game.ini', 'a')
      elevatedPrioText = Game_Priority::Elevated_Priority_Text
      gameini.write("\n#{elevatedPrioText}#{high_priority}\n")
      gameini.close
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose of Windows
  #--------------------------------------------------------------------------
  def dispose_windows
    @text_window.dispose
    @selection_window.dispose
  end
end



#==============================================================================
# ** Read from the Game.ini file
#------------------------------------------------------------------------------
#  This section of code checks the Game.ini file to see if the
#  priority flag has been set.
#==============================================================================
# Read the contents of the Game.ini file
gameini = File.open('Game.ini', 'r+')
gameini_text = gameini.read
gameini.close
# Load what text to look for in the Game.ini file
elevatedPrioText = Game_Priority::Elevated_Priority_Text
# Check to see if the Game.ini has the ElevatedPriority flag
if (gameini_text =~ /#{elevatedPrioText}(true|false)/) != nil
  # If it did, set it to what was found
  Game_Priority.elevated_priority = ($1 == "true")
else
  # If it didn't have the priority flag: let the player select
  Scene_ChoosePriority.new.main
end