class Scene_Lobby
  def main
    
    @command_choice = Window_Command.new(['Host Game', 'Join Game', 'To Title'])
    @user_logger = Window_Base.new(160, 160, 480, 320)
    @user_logger.visible = false
    
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    
    @command_choice.dispose
    @user_logger.dispose
    
    
  end
  
  def update
    case @phase
    when 0 then update_command_choice
    end
  end
  
  def update_command_choice
    @command_choice.update
    if Input.trigger?(Input::C)
      case @command_choice.index
      when 0 # Host Game
        @phase = ?????
        system('run CServer.exe')
      when 1 # Join Game
        @phase = ?????
      end
      @command_choice.active = false
      @command_choice.visible = false
    elsif Input.trigger?(Input::B)
      $scene = Scene_Title.new
    end
  end
  
  def update_connection_input
    
  end
  
  def update_name_input
    
  end
  
  
  
end
