=begin
___________________
 Game_Event        \____________________________________________________________
 
 Small method that allows pre-deployed units. Events on the map that have a
 Comment command as the first event command are processed to see if it follows
 the rules to be a pre-deployed unit. I should make it more friendly later on
 (e.g. Error messages for invalid syntax and continue)
 
 Notes:
 * Credit to Game_Guy for learning about this method
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Game_Event < Game_Character
  attr_reader :event    # For '.get' purposes; is a 'RPG::Event' value
  #--------------------------------------------------------------------------
  # Reads special comment code that defines a unit. Pushes the result into
  # Game_Map.units
  #--------------------------------------------------------------------------
  def unit_processing(code)
    a = code.split(':') # Unit : Army : HP : Fuel : Ammo
    return if a.size < 2
    type   = a[0]
    army   = $game_map.set_unit_army(a[1].to_i)
    # Stores the unit data into the map data table
    eval("$game_map.map_data[self.x, self.y].unit = #{type}.new(self.x, self.y, army)")
    $game_map.get_unit(self.x,self.y).health = a[2].to_i if a.size >= 3
    $game_map.get_unit(self.x,self.y).fuel   = a[3].to_i if a.size >= 4
    $game_map.get_unit(self.x,self.y).ammo   = a[4].to_i if a.size >= 5
    army.add_unit($game_map.get_unit(self.x,self.y))
  end
end
=begin
________________
 AW_Data        \_______________________________________________________________
 
 A class that just holds data. Could basically be a 2-element array. An instance
 of this class is created for every tile on the map. It holds the tile and unit
 currently at its location. All of these are held in a 2D-Array in Game_Map.
 
 Notes:
 * 
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class AW_Data
  attr_accessor :tile, :unit
  
  def initialize
    @tile = nil
    @unit = nil
  end
  
end
=begin
_________________
 Game_Map        \______________________________________________________________
 
 Data of the current map. Holds vital information like number of players, what
 tiles are at what spot, Fog of War flag, size of map, and such. Currently an
 extension of the RPG Maker class, so I should probably separate them.
 
 Notes:
 * 
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Game_Map
  attr_accessor :frame_count    # Universal frame count
  attr_accessor :map_data        # Holds tile and unit data in a table
  attr_accessor :army           # Array that holds all the Army classes
  attr_accessor :day
  attr_accessor :weather
  attr_reader :map
  attr_reader :fow
  
  #--------------------------------------------------------------------------
  # * Setup - Defines pre-deployed units and properties on map.
  #           This method is called once only BEFORE the battle starts.
  #--------------------------------------------------------------------------
  def setup(map_id, officers = nil)
    # Set up the frame count
    @frame_count = 0
    # Start day counter
    @day = 1
    # Setup weather
    @weather = [0, 0, 'none', false]
    
    # Is Fog of War on?
    @fow = false#true
    
    # Put map ID in @map_id memory
    @map_id = map_id
    # Load map from file and set @map
    @map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))

    # Define armies
    @army = []
    if officers.nil? # For those testing purposes only. Probably will be removed
      @army[0] = Army.new(1, 0, "Andy")
      @army[1] = Army.new(2, 1, "Drake")
    else
      @map.army_setup.each_index{|i|
        player = @map.army_setup[i]
        next if player == 0
        @army[player-1] = Army.new(player, i, officers[player-1].name)
      }
    end
    
    # Create data table of the map
    @map_data = Array2D.new(@map.width, @map.height)
    # set tile set information in opening instance variables
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    # Initialize displayed coordinates
    @display_x = 0
    @display_y = 0
    # Clear refresh request flag
    @need_refresh = false
    # Initialize map tiles
    for y in 0..@map.height-1
      for x in 0..@map.width-1
        # Initialize the data at [x,y]
        @map_data[x,y] = AW_Data.new
        # Get the tile located at (x,y)
        tile = terrain_tag(x,y)
        @map_data[x,y].tile = tile
        # Add top layer graphic if a Woods or Mountain tile
        if tile.is_a?(Woods) or tile.is_a?(Mountains) and y-1 >= 0
          @map.data[x,y-1,1] = $game_map.data[x,y,0] - 8
        end
        # If the tile is a property, define army ownership
        if tile.is_a?(Property)
          tile.x = x
          tile.y = y
          owner = Config.army_ownership(data[x, y, 0])
          prop_army(x, y, owner)
          # Sets the starting cursor location on the Headquarters
          owner.set_cursor(x,y) if tile.is_a?(HQ)
        elsif tile.is_a?(Structure)
          tile.x, tile.y = x, y
        end
      end
    end
    # Reload the map back into the file for any graphical changes to the layers
    mapfile = File.open(sprintf("Data/Map%03d.rxdata", @map_id), "w")
    Marshal.dump(@map, mapfile)
    mapfile.close
    # Set map event data. Get all events on the map. Needed for unit intialization.
    @events = {}
    for i in @map.events.keys
      event_pos = Game_Event.new(@map_id, @map.events[i])
#=begin
      # If the event has a special comment command on page 1 at beginning...
      # 108 = Comment code, 408 = multi-line Comment code
      if [108].include?(event_pos.event.pages[0].list[0].code) 
        # Interprets the special comment command
        event_pos.unit_processing(event_pos.event.pages[0].list[0].parameters[0])
        next
      end
#=end
      @events[i] = event_pos
    end
    # Set common event data
    @common_events = {}
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
    # Initialize all fog information
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    # Initialize scroll information
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end
  #--------------------------------------------------------------------------
  # * prop_army - Changes the owner of the property at [x,y]
  #--------------------------------------------------------------------------
  def prop_army(x, y, army)
    return unless @map_data[x,y].tile.is_a?(Property)
    @map_data[x,y].tile.army = army
    # Adds the property to the army's owned properties array unless the
    # property now belongs to no one
    army.owned_props.push(@map_data[x,y].tile) if army != 0
  end
  #--------------------------------------------------------------------------
  # * Return the tile located at [x,y]
  #--------------------------------------------------------------------------
  def get_tile(x, y)
    return nil unless valid?(x,y)
    return @map_data[x,y].tile
  end
  #--------------------------------------------------------------------------
  # * Set the unit to [x,y]
  #--------------------------------------------------------------------------
  def set_unit(x, y, unit)
    return nil unless valid?(x,y)
    @map_data[x,y].unit = unit
  end
  #--------------------------------------------------------------------------
  # * Return the unit located at [x,y]
  #--------------------------------------------------------------------------
  def get_unit(x, y, return_hiding=true)
    return nil unless valid?(x,y)
    unit = @map_data[x,y].unit
    # If the unit is invisible and don't want to return hidden units
    if unit.is_a?(Unit) and !unit.exposed and !return_hiding
      return nil
    end
    return unit
  end
  #--------------------------------------------------------------------------
  # * Return if the unit is visible on the screen
  #--------------------------------------------------------------------------
  def unit_onscreen?(unit)
    ux = unit.x * 128 
    uy = unit.y * 128
    if @display_x <= ux and ux < @display_x + 2560 and
      @display_y <= uy and uy < @display_y + 1920
      return true
    else 
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * Returns an array of all the units on the map
  #--------------------------------------------------------------------------
  def units
    armyunits = []
    @army.each{|army| next if army.nil? ; armyunits += army.units}
    return armyunits
  end
  #--------------------------------------------------------------------------
  # * Set the unit's army type (for initialization)
  #--------------------------------------------------------------------------
  def set_unit_army(id)
    if id.is_a?(Integer)
      return @army[id-1]
    else
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # * Return units around this unit
  #--------------------------------------------------------------------------
  def get_nearby_units(x, y)
    spaces = []  
    spaces.push(get_unit(x, y-1))
    spaces.push(get_unit(x+1, y))
    spaces.push(get_unit(x, y+1))
    spaces.push(get_unit(x-1, y))
    return spaces
  end
  #--------------------------------------------------------------------------
  # * Return tiles around this unit
  #--------------------------------------------------------------------------
  def get_nearby_tiles(x, y)
    spaces = []
    spaces.push(get_tile(x, y-1))
    spaces.push(get_tile(x+1, y))
    spaces.push(get_tile(x, y+1))
    spaces.push(get_tile(x-1, y))
    return spaces
  end
  #--------------------------------------------------------------------------
  # * Return all coordinates within 'range' spaces of [x,y]
  #--------------------------------------------------------------------------
  def get_spaces_in_area(x,y,range=1)
    return unless valid?(x,y)
    # Push first spot
    positions = [[x,y]]
    # Calculate ranges in a clockwise direction, radiating outwards
    for r in 1..range
      positions.push([x, y-r])
      loop do
        next_spot = [positions[positions.size-1][0]+1,positions[positions.size-1][1]+1]
        positions.push(next_spot)
        break if next_spot[1] == y
      end
      loop do
        next_spot = [positions[positions.size-1][0]-1,positions[positions.size-1][1]+1]
        positions.push(next_spot)
        break if next_spot[0] == x
      end
      loop do
        next_spot = [positions[positions.size-1][0]-1,positions[positions.size-1][1]-1]
        positions.push(next_spot)
        break if next_spot[1] == y
      end
      loop do
        next_spot = [positions[positions.size-1][0]+1,positions[positions.size-1][1]-1]
        break if next_spot[0] == x
        positions.push(next_spot)
      end
    end
    return positions
  end
  #--------------------------------------------------------------------------
  # Creates the weather. 'type' refers to what type of weather.
  #--------------------------------------------------------------------------
  def set_weather(type = 'none', days_of_effect = 0)
    case type
    when 'snow'
      @weather = [@day, $scene.player, 'snow', days_of_effect]
      $game_screen.weather(3, 20, 0)
    when 'rain'
      @weather = [@day, $scene.player, 'rain', days_of_effect]
      #$game_screen.weather(1, 20, 0)
      $game_screen.weather(1, 25, 40, 1)
    when 'sand'
      @weather = [@day, $scene.player, 'sand', days_of_effect]
      
    else
      @weather = [@day, $scene.player, 'none', days_of_effect]
      $game_screen.weather(0, 0, 0)
    end
  end
  #--------------------------------------------------------------------------
  # Checks if the current weather needs to stop
  #--------------------------------------------------------------------------
  def turn_weather_off(player_turn)
    if @weather[0] + @weather[3] == @day and @weather[1] == player_turn
      set_weather('none')
    end
  end
  
  #--------------------------------------------------------------------------
  # Returns the weather playing on the map
  #--------------------------------------------------------------------------
  def current_weather
    return @weather[2]
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Refresh map if necessary
    if $game_map.need_refresh
      refresh
    end
    # If scrolling
    if @scroll_rest > 0
      # Change from scroll speed to distance in map coordinates
      distance = 2 ** @scroll_speed
      # Execute scrolling
      case @scroll_direction
      when 2  # Down
        scroll_down(distance)
      when 4  # Left
        scroll_left(distance)
      when 6  # Right
        scroll_right(distance)
      when 8  # Up
        scroll_up(distance)
      end
      # Subtract distance scrolled
      @scroll_rest -= distance
    end
    # Update map event
    for event in @events.values
      event.update
    end
    # Update common event
    for common_event in @common_events.values
      common_event.update
    end
    # Manage fog scrolling
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    # Manage change in fog color tone
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    # Manage change in fog opacity level
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
    
  end
  #--------------------------------------------------------------------------
  # * Get Terrain Tag (edit) ### ONLY CHECKS THE TILE AT THE BOTTOM LAYER ###
  #     x          : x-coordinate
  #     y          : y-coordinate
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    if @map_id != 0
      tile_id = data[x, y, 0]
      if tile_id == nil
        return nil
      else
        # if tile is an autotile, returns terrain tag based on Database
        if tile_id < 384
          return @terrain_tags[tile_id]
          # calls a method that determines the terrain tag
        else
          owner = Config.army_ownership(tile_id)
          return Config.terrain_tag(tile_id, 0, 0, owner)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Terrain Cost (for unit moving)
  #--------------------------------------------------------------------------
  def terrain_cost(unit, x, y)
    return get_tile(x,y).move_cost(unit)
  end
  
  def valid?(x,y)
    return false if x.nil? || y.nil?
    return (x >= 0 and x < @map.width and y >= 0 and y < @map.height)
  end
  
end


