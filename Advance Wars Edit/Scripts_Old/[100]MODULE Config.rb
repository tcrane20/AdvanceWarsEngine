=begin
_______________
 Config        \________________________________________________________________
 
 All the configuration needed for the prototypical game. I think some of these
 should be moved to the class it better represents (music loops for example).
 
 Notes:
 * Is this class necessary? Can't I append it to Unit Sprite?
 * Combine all flags and HP flags into one file
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
module Config
  TILESET_NAME = "dummy_tileset"
  #----------------------------------------------------------------------------
  # * terrain_tag
  # Returns a variable defined in the global variables tab.
  # The x,y,army arguments are needed for property initialization.
  # when map.data[x,y] then return tile ID
  #----------------------------------------------------------------------------
  def self.terrain_tag(tile_id, x=0, y=0, army=0)
    case tile_id
    when 384,530,548,549 then return Plains.new
    when 192..239, 385 then return Sea.new
    when 386..398 then return Road.new
    when 399..410 then return Shoal.new
    when 411..421 then return River.new
    when 429 then return Reef.new
    when 430 then return Woods.new
    when 431 then return Mountains.new
    when 432..438 then return City.new(x,y,army)
    when 448..452 then return Factory.new(x,y,army)
    when 464..467 then return HQ.new(x,y,army)
    when 480..484 then return Airport.new(x,y,army)
    when 496..500 then return Seaport.new(x,y,army)
    when 512..518 then return ComTower.new(x,y,army)
    when 528 then return Silo.new(x,y,false)
    when 529 then return Silo.new(x,y,true)
    when 547 then return Pipe_Joint.new(x,y,false) # Vertical joint
    when 546 then return Pipe_Joint.new(x,y,true)  # Horizontal joint
    when 560 then return Minicannon.new(x,y,8)
    when 561 then return Minicannon.new(x,y,6)
    when 562 then return Minicannon.new(x,y,2)
    when 563 then return Minicannon.new(x,y,4)
    when 577 then return BlackCannon.new(x,y,2)
    when 580 then return BlackCannon.new(x,y,8)
    when 556 then return LaserCannon.new(x,y)
    else return Pipe.new
    end
  end
  #----------------------------------------------------------------------------
  # * army_ownership
  # Returns the army owning the property. Only count the main tile graphic, not
  # the secondary bits that extend beyond the 32 x 32 square.
  # when map.data[x,y] then return army ID
  #----------------------------------------------------------------------------
  def self.army_ownership(tile_id)
    if [433, 449, 464, 481, 497, 513].include?(tile_id)
      return $game_map.army[0]
    elsif [434, 450, 465, 482, 498, 514].include?(tile_id)
      return $game_map.army[1]
    elsif [435, 451, 466, 483, 499, 515].include?(tile_id)
      return $game_map.army[2]
    elsif [436, 452, 467, 484, 500, 516].include?(tile_id)
      return $game_map.army[3]
    else 
      return 0
    end
  end
  #----------------------------------------------------------------------------
  # * minimap_tiles
  # Determines what minimap graphic to draw based on the passed tile parameters
  #----------------------------------------------------------------------------
  def self.minimap_tiles(tile_type, tile_id)
    case tile_type.id
    when TILE_PLAINS then return 0
    when TILE_SEA then return 3
    when TILE_REEF then return 5
    when TILE_ROAD then return 6
    when TILE_SHOAL then return 4
    when TILE_RIVER then return 7
    when TILE_WOODS then return 1
    when TILE_MOUNTAINS then return 2
    when TILE_CITY, TILE_FACTORY, TILE_AIRPORT, TILE_SEAPORT, TILE_COMTOWER, TILE_HQ
      case tile_id
      when 433, 449, 464, 481, 497, 513 then return 9
      when 434, 450, 465, 482, 498, 514 then return 10
      when 435, 451, 466, 483, 499, 515 then return 12
      else
        return 8
      end
    when TILE_SILO then return 13
    when TILE_JOINT then return 14
    else
      return 15
    end
  end
  
  #----------------------------------------------------------------------------
  # * status_effect
  # Defines status effects units may have. These only alter individual stats.
  # 
  # The procedure to do this is as follows:
  # return [CURES, EFFECT_TYPE, AMOUNT, EFFECT_TYPE, AMOUNT, ... ]
  # CURES - How many days it takes to cure the effect. A value of 0 means that
  #         the status effect only lasts until the current player's turn ends.
  # EFFECT_TYPE - A string value that indicates what stat is affected. Types:
  #    'move','cost','repair','repair_cost','vision','offense','defense','capture','posluck','negluck'
  # AMOUNT - How much the affected stat decreases(-)/increases(+)
  #----------------------------------------------------------------------------
  def self.status_effect(id)
    case id
    when 0 # Rachel's Covering Fire debuff: Reduces defenses by 20 during her turn
      return [0, 'defense', -20]
    when 1 # Sensei's Airborne Assault buff: Raises attack of spawned mechs
      return [1, 'offense', 20]
    else
      return nil
    end
  end
  
  #----------------------------------------------------------------------------
  # * get_color
  # For ranges; there's only two
  #----------------------------------------------------------------------------
  def self.get_color(type)
    case type
    when 1 then return Color.new(0,0,255,255) # Move Color
    when 2 then return Color.new(255,0,0,255) # Attack Color
    end
  end
  #----------------------------------------------------------------------------
  # * play_se
  # when "name" then play (audio file location, volume)
  #----------------------------------------------------------------------------
  def self.play_se(type)
    case type
    when "cursor" then Audio.se_play("Audio/SE/maptick", 85)
    when "decide" then Audio.se_play("Audio/SE/select", 90)
    when "pageturn" then Audio.se_play("Audio/SE/open map", 100)
    when "cheer" then Audio.se_play("Audio/SE/cheer", 90)
    when "load" then Audio.se_play("Audio/SE/load", 70)
    when "drop" then Audio.se_play("Audio/SE/unload", 70)
    when "target" then Audio.se_play("Audio/SE/target", 70)
    when "power" then Audio.se_play("Audio/SE/power", 100)
    when "superpower" then Audio.se_play("Audio/SE/superpower", 100)
    when "foot" then Audio.bgs_play("Audio/BGS/movement foot", 100)
    when "plane" then Audio.bgs_play("Audio/BGS/movement plane", 100)
    when "b_plane" then Audio.bgs_play("Audio/BGS/movement plane", 100, 80)
    when "tread" then Audio.bgs_play("Audio/BGS/movement tracks", 100)
    when "wheels" then Audio.bgs_play("Audio/BGS/movement wheels", 80)
    when "m_tread" then Audio.bgs_play("Audio/BGS/movement tracks", 100, 75)
    when "h_tread" then Audio.bgs_play("Audio/BGS/movement tracks", 100, 60)
    when "copter" then Audio.bgs_play("Audio/BGS/movement helicopter", 100)
    when "ship" then Audio.bgs_play("Audio/BGS/movement ship", 100)
    when "income" then Audio.bgs_play("Audio/BGS/income loop", 100)
    when "income_end" then Audio.se_play("Audio/SE/income end", 100)
    end
  end
  #----------------------------------------------------------------------------
  # * get_command_icon
  # For command window. Determines what icon to draw based on the action.
  #----------------------------------------------------------------------------
  def self.get_command_icon(command)
    case command
    when "Wait" then return "unit_wait"
    when "Join" then return "unit_join"
    when "Fire" then return "unit_fire"
    when "Fire " then return "unit_nofire"
    when "Load" then return "unit_load"
    when "Capt" then return "unit_capt"
    when "Supply" then return "unit_supply"
    when "Launch" then return "unit_fire"
    when "Dive","Hide" then return "unit_hide"
    when "Surface","Appear" then return "unit_appear"
    when "End Turn" then return "end_turn"
    when "Power" then return "co_power"
    when "Super Power" then return "co_spower"
    when "CO" then return "co_bio"
    else return "unit_wait"
    end
  end
  #----------------------------------------------------------------------------
  # * get_music_format
  # Sets the music loop points
  #----------------------------------------------------------------------------
  def self.get_music_format(name)
    volume = 100 # Default volume level
    loop = 0 # Loop point (in milliseconds)
    fin = -1 # End of song (in milliseconds)
    case name
    when "Andy"
      loop = 5000
      fin = 75500
    when "Max"
      loop = 10100
      fin = 80100
    when "Sami"
      loop = 15200
      fin = 76190
      volume = 80
    when "Nell"
      loop = 15300
      fin = 76300
      volume = 100
    when "Hachi"
      loop = 11975
      fin = 68000
    when "Jake"
      loop = 5400
      fin = 96120
      volume = 85
    when "Rachel"
      loop = 1000
      fin = 62500
      volume = 85
    when "Olaf"
      loop = 2170
      fin = 59450
    when "Colin"
      loop = 7100
      fin = 75700
      volume = 85
    when "Grit"
      loop = 12300
      fin = 65150
      volume = 85
    when "Sasha"
      loop = 15990
      fin = 105800
    when "Kanbei"
      loop = 4630
      fin = 59500
    when "Sonja"
      loop = 8100
      fin = 64100
    when "Sensei"
      loop = 2200
      fin = 65500
    when "Grimm"
      loop = 8450
      fin = 72500
    when "Eagle"
      loop = 0
      fin = 67865
      volume = 90
    when "Drake"
      loop = 16100
      fin = 76450
    when "Jess"
      loop = 43670
      fin = 109150
    when "Javier"
      loop = 22050
      fin = 74750
    when "Flak"
      loop = 19270
      fin = 87700
    when "Lash"
      loop = 23040
      fin = 72500
    when "Adder"
      loop = 21650
      fin = 81700
    when "Hawke"
      loop = 18500
      fin = 81300
      volume = 90
    when "Jugger"
      loop = 8100
      fin = 81750
    when "Koal"
      loop = 14150
      fin = 103600
    when "Kindle"
      loop = 1950
      fin = 63900
    when "Von Bolt"
      loop = 46700
      fin = 113150
    when "Power"
      loop = 1070
      fin = 45450
      volume = 90
    when "SuperPower"
      loop = 1200
      fin = 49200
      volume = 90
    when "BHPower"
      loop = 1090
      fin = 49950
    when "BHSuperPower"
      loop = 1730
      fin = 36300
    when "WarsWorldNews"
      loop = 9300
      fin = 41420
      volume = 50
    when "Titus"
      volume = 40
      loop = 900
      fin = 58135
    when "Markus"
      volume = 70
      loop = 100
      fin = 69875
    end
    volume = 50
    return loop, fin, volume
    
  end
end

