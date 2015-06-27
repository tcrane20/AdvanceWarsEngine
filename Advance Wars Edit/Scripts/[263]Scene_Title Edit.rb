=begin
____________________
 Scene_Title        \___________________________________________________________
 
 Second scene that the player is brought to, immediately after the introduction.
 Currently just the stock RPG Maker class with the New Game command sending the
 player to the Main Menu scene. Also loads COs and Units into memory for calling
 back to later on.
 
 Notes:
 * This scene should be changed to only display a PRESS START message.
 * The loading of COs and Units might need to be changed. I'll have to look more
 into our options.
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Scene_Title
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # If battle test
    if $BTEST
      battle_test
      return
    end
    
    
    
    $CO.each_index{|i| $CO[i] = $CO[i].new }
    
=begin
    maps = {}
    for i in 0..30
    maps[i] = RPG::MapInfo.new
    maps[i].name = "Map#{i}"
    maps[i].parent_id = 0
    maps[i].order = i
    maps[i].expanded = false
    maps[i].scroll_x = 20*16
      maps[i].scroll_y = 15*16
    end
    
    file = File.open("Data/MapInfos.rxdata", "wb")
    Marshal.dump(maps, file)
    file.close
=end

    #maps = load_data("Data/MapInfos.rxdata")
    #maps.each_value{|m| p m}
    #puts maps.keys.sort
=begin
    maps[6] = maps[1]
    maps[6].name = "Castle"
    maps[6].parent_id = 0
    maps[6].order = 6
    maps[6].expanded = false
    maps[6].scroll_x = 36*16
    maps[6].scroll_y = 36*18
    File.open("Data/MapInfos.rxdata", "wb")
    Marshal.dump(maps, "Data/MapInfos.rxdata")
    File.close
    maps = load_data("Data/MapInfos.rxdata")
    maps.each_key{|m| puts m}
    puts maps.keys.sort
=end
    # Load database
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # Make system object
    $game_system = Game_System.new
    # Make title graphic
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # Make command window
    s1 = "Local Game"
    s2 = "Online Game"
    s3 = "Shutdown"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    #@command_window.back_opacity = 160
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
    # Play title BGM
    $game_system.bgm_play($data_system.title_bgm)
    # Stop playing ME and BGS
    Audio.me_stop
    Audio.bgs_stop
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      
      
      
      if Input.trigger?(Input::Key['T'])
        @win = Dialogue_Window.new#(0,0,480,200)
      end
      
      if Input.trigger?(Input::Key['R'])
        @win.set_window("Andy")
        @win.add_text("Hey Nell. You called me?")
        @win.set_window("Nell")
        @win.add_text("Oh Andy, it's a good thing you're here. I need help with something.")
        @win.add_text("See that man over there?")
        @win.set_window("Flak", 1, false)
        @win.add_text("Hah hah hah...lady looking fiiiiiiiiine today.", 60)
        @win.set_window("Nell", 2)
        @win.add_text("He's a total creep.")
        @win.set_window("Andy", 2)
        @win.add_text("What's so wrong about that?")
        @win.set_window("", 1)
        @win.add_text("He's just giving you a compliment. I agree that you are looking fine today too.")
        @win.set_window("Nell", 2)
        @win.add_text("...")
      end
      
      
      
      
      
      
      
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of command window
    @command_window.dispose
    # Dispose of title graphic
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Command: New Game
  #--------------------------------------------------------------------------
  def command_new_game
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Stop BGM
    Audio.bgm_stop
    # Reset frame count for measuring play time
    Graphics.frame_count = 0
    # Make each type of game object
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # Set up initial party
    $game_party.setup_starting_members
    # Refresh game player
    $game_player.refresh
    # Switch to map screen
    $scene = Scene_MainMenu.new
  end
  #--------------------------------------------------------------------------
  # * Command: Continue
  #--------------------------------------------------------------------------
  def command_continue
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Switch to load screen
    $scene = Scene_Lobby.new
  end
end
