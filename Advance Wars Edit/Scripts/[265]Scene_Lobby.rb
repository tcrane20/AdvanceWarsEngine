class Scene_Lobby
  #----------------------------------------------------------------------------
  # 
  #----------------------------------------------------------------------------
  def main
    
    # Make title graphic
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    
    @command_choice = Window_Command.new(200,['Host Game', 'Join Game', 'To Title'])
    @command_choice.x = 220
    @command_choice.y = 150
    @command_choice.active = true
    
    @user_logger = Window_Base.new(220, 160, 200, 160)
    @user_logger.visible = false

    # Name
    @name_input_textbox = Frame_Text.new(200, 150, 200, 28)
    @name_input_textbox.max_length = 16
    @name_input_textbox.input_filter = /([\W])/
    @name_input_textbox.visible = false
    @name_input_textbox.active = false
    @name_input_label = Sprite.new
    @name_input_label.bitmap = Bitmap.new(150,32)
    @name_input_label.bitmap.draw_text(0,0,150,32,"Username:")
    @name_input_label.x, @name_input_label.y = 80, 150
    @name_input_label.visible = false
    

    # IP Address
    @ipaddress_textbox = Frame_Text.new(200, 180, 200, 28)
    @ipaddress_textbox.max_length = 15
    @ipaddress_textbox.input_filter = /([a-zA-Z_]|\s)/
    @ipaddress_textbox.visible = false
    @ipaddress_textbox.active = false
    @ipaddress_label = Sprite.new
    @ipaddress_label.bitmap = Bitmap.new(150,32)
    @ipaddress_label.bitmap.draw_text(0,0,150,32,"IP Address:")
    @ipaddress_label.x, @ipaddress_label.y = 80, 180
    @ipaddress_label.visible = false

    # Port Number
    @port_textbox = Frame_Text.new(200, 210, 100, 28)
    @port_textbox.max_length = 5
    @port_textbox.input_filter = /([\D])/
    @port_textbox.visible = false
    @port_textbox.active = false
    @port_label = Sprite.new
    @port_label.bitmap = Bitmap.new(150,32)
    @port_label.bitmap.draw_text(0,0,150,32,"Port:")
    @port_label.x, @port_label.y = 80, 210
    @port_label.visible = false
    
    @phase = 0
    
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
    
    @sprite.dispose
    @command_choice.dispose
    @user_logger.dispose
    
    
  end
  #----------------------------------------------------------------------------
  # Disposes the additional background sprite.
  #----------------------------------------------------------------------------
  def update
    case @phase
    when 0 then update_command_choice
    when 1 then update_host_game
    when 2 then update_join_game
    when 3 then update_lobby
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
        #system('run CServer.exe')
        @name_input_textbox.visible = true
        @name_input_label.visible = true
        @name_input_textbox.active = true
        @port_textbox.visible = true
        @port_label.visible = true
      when 1 # Join Game
        @phase = 2
        @name_input_textbox.visible = true
        @name_input_textbox.active = true
        @name_input_label.visible = true
        @ipaddress_textbox.visible = true
        @ipaddress_label.visible = true
        @port_textbox.visible = true
        @port_label.visible = true
      when 2
        $scene = Scene_Title.new
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
  def update_host_game
    if @name_input_textbox.active
      @name_input_textbox.update
      if Input.trigger?(Input::DOWN) || @port_textbox.clicked_on?
        @port_textbox.active = true
        @name_input_textbox.active = false
      end
    else
      @port_textbox.update
      if Input.trigger?(Input::UP) || @name_input_textbox.clicked_on?
        @name_input_textbox.active = true
        @port_textbox.active = false
      end
    end
    
    if Input.trigger?(Input::Key['Enter'])
      @phase = 3
      @user_logger.visible = true
      @name_input_textbox.active = false
      @port_textbox.active = false
        
      @name_input_textbox.visible = false
      @name_input_label.visible = false
      @port_textbox.visible = false
      @port_label.visible = false
    end
  end
  #----------------------------------------------------------------------------
  # Disposes the additional background sprite.
  #----------------------------------------------------------------------------
  def update_join_game

    if @name_input_textbox.active
      @name_input_textbox.update
      if Input.trigger?(Input::DOWN)
        @ipaddress_textbox.active = true
        @name_input_textbox.active = false
        return
      end
    elsif @ipaddress_textbox.active
      @ipaddress_textbox.update
      if Input.trigger?(Input::DOWN)
        @port_textbox.active = true
        @ipaddress_textbox.active = false
        return
      elsif Input.trigger?(Input::UP)
        @name_input_textbox.active = true
        @ipaddress_textbox.active = false
        return
      end
    else
      @port_textbox.update
      if Input.trigger?(Input::UP)
        @ipaddress_textbox.active = true
        @port_textbox.active = false
        return
      end
    end
    
    if @name_input_textbox.clicked_on?
      @name_input_textbox.active = true
      @ipaddress_textbox.active =  false
      @port_textbox.active =       false
    elsif @ipaddress_textbox.clicked_on?
      @name_input_textbox.active = false
      @ipaddress_textbox.active =  true
      @port_textbox.active =       false
    elsif @port_textbox.clicked_on?
      @name_input_textbox.active = false
      @ipaddress_textbox.active =  false
      @port_textbox.active =       true
    end
    
    if Input.trigger?(Input::Key['Enter'])
      if @ipaddress_textbox.text.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) == []
        return
      end
      @phase = 3
      @user_logger.visible = true
      @name_input_textbox.active = false
      @ipaddress_textbox.active =  false
      @port_textbox.active =       false
      
      @name_input_textbox.visible = false
      @name_input_label.visible = false
      @ipaddress_textbox.visible = false
      @ipaddress_label.visible = false
      @port_textbox.visible = false
      @port_label.visible = false
    end
    
  end
  
  
  
  def update_lobby
    @user_logger.update
  end
  
  
end
