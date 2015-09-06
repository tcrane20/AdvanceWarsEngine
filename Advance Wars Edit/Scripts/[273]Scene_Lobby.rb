class Scene_Lobby
  #----------------------------------------------------------------------------
  # 
  #----------------------------------------------------------------------------
  def main
    
    @command_choice = Window_Command.new(['Host Game', 'Join Game', 'To Title'])
    @user_logger = Window_Base.new(160, 160, 480, 320)
    @user_logger.visible = false

    @name_input_textbox = Frame_Caption.new(200, 150, 200, "Name")
    @name_input_textbox.visible = false
    @name_input_textbox.active = false

    @ipaddress_textbox = Frame_Caption.new(200, 180, 200, "IP Address")
    @ipaddress_textbox.visible = false
    @ipaddress_textbox.active = false

    @port_textbox = Frame_Caption.new(200, 210, 100, "Port Number")
    @port_textbox.visible = false
    @port_textbox.active = false
    
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
  #----------------------------------------------------------------------------
  # Disposes the additional background sprite.
  #----------------------------------------------------------------------------
  def update
    case @phase
    when 0 then update_command_choice
    when 1 then update_connection_input
    when 2 then update_name_input
    when 3 then update_
    end
  end
  #----------------------------------------------------------------------------
  # Disposes the additional background sprite.
  #----------------------------------------------------------------------------
  def update_command_choice
    @command_choice.update
    if Input.trigger?(Input::C)
      case @command_choice.index
      when 0 # Host Game
        @phase = 1
        system('run CServer.exe')
        @name_input_textbox.visible = true
        @port_textbox.visible = true
      when 1 # Join Game
        @phase = 2
        @ipaddress_textbox.visible = true
        @port_textbox.visible = true
      end
      @command_choice.active = false
      @command_choice.visible = false
    elsif Input.trigger?(Input::B)
      $scene = Scene_Title.new
    end
  end
  #----------------------------------------------------------------------------
  # Disposes the additional background sprite.
  #----------------------------------------------------------------------------
  def update_connection_input
    @name_input_textbox.update
    
  end
  #----------------------------------------------------------------------------
  # Disposes the additional background sprite.
  #----------------------------------------------------------------------------
  def update_name_input
    
  end
  
  
  
end
