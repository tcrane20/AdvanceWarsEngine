=begin
_______________________
 Scene_MainMenu        \________________________________________________________
 
 Main scene that currently occurs after title. Draws selectable window
 displaying map names. Highlighting a map draws its respective minimap. The
 player selects a map and is brought to the CO Select screen.
 
 Notes:
 * This scene should be changed to the central hub of the game, where the player
 can select Campaign, Versus, Options, etc.
 * This map select scene should be named something else and be in its own
 separate scene class.
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Scene_MainMenu
  #-----------------------------------------------------------------------------
	# * Called when new object created
	#-----------------------------------------------------------------------------
	def initialize
    # Create command window
		@map_select = Window_MapSelect.new
		@phase = 0
    # Array of selected COs from coming out of the CO select screen
		@saved_player_COs = nil
    # Create background image
		@background = Plane.new
		@background.z = -1000
		@background.bitmap = RPG::Cache.panorama("AWXP_BG", 255)
	end
  #-----------------------------------------------------------------------------
	# * Main scene process
	#-----------------------------------------------------------------------------
	def main
		Graphics.transition
    $game_system.bgm_play("WarsWorldNews")
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
    Audio.bgm_stop
		@map_select.dispose
		@map_select = nil
		Graphics.freeze
		@background.dispose
	end
  #-----------------------------------------------------------------------------
	# * Updates the scene for controls
	#-----------------------------------------------------------------------------
	def update
		
		case @phase
		when 0 # Map select phase
			@map_select.update
      # Select a map from the list
			if Input.trigger?(Input::C)
        Config.play_se("decide")
        # Go to CO select phase
				@phase = 1
        # Get this map's ID (to load and setup later)
				@map_id = @map_select.get_map
        # Loads map into game
        map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
        # Hide map selection list
				@map_select.active = false
				@map_select.visible = false
        #@co_select = CO_Select.new(@saved_player_COs,2)
        # Start up the CO Select scene
				@co_select = CO_Select.new(@saved_player_COs,map.army_setup)
			end
		when 1 # CO Select phase
			@co_select.update
      # Moving to a new scene (most likely Scene_Map)
			if $scene != self
        # New game map instance
				$game_map = Game_Map.new
        # Set up map with data
				$game_map.setup(@map_id, @co_select.player_COs)
				return
			end
      # Pressed B to return to map select
			if @co_select.go_back
				@phase = 0
				@map_select.active = true
				@map_select.visible = true
        # Saves the COs the player(s) have selected for recalling later
				@saved_player_COs = @co_select.player_COs
			end
		end
		
	end
	
end
