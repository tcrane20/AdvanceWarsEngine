#============================================================================
# Stores all data for each type of terrain. Each tile on the map is initialized
# and stored in a Table in the Map Data.
#============================================================================
class Tile
  attr_accessor :name, :id, :defense, :fow_cover, :vision
  
  def initialize(*args)
    @name = ''
    @id = 0
    @defense = 0
    @fow_cover = false
    @vision = 0
  end
  
  def move_cost(unit)
    if ($game_map.current_weather == 'snow' and !unit.army.officer.no_snow_penalty) or
      ($game_map.current_weather == 'rain' and unit.army.officer.name == 'Olaf')
      # Snow movechart
      case unit.move_type
      when MOVE_FOOT then return 1
      when MOVE_MECH then return 1
      when MOVE_TIRE then return 1
      when MOVE_TREAD then return 1
      when MOVE_AIR then return 2
      when MOVE_TRANS then return 0
      when MOVE_SEA then return 0
      when MOVE_TIRE_B then return 1
      end
    else
      # Normal movechart
      case unit.move_type
      when MOVE_FOOT then return 1
      when MOVE_MECH then return 1
      when MOVE_TIRE then return 1
      when MOVE_TREAD then return 1
      when MOVE_AIR then return 1
      when MOVE_TRANS then return 0
      when MOVE_SEA then return 0
      when MOVE_TIRE_B then return 1
      end
    end
  end
  
  def fow_bonus(unit)
    return 0
  end
  
  #-------------------------------------------------------------------------
  #  Checks if the specified unit can be repaired on this tile. Define
  # this method in each type of tile class.
  #-------------------------------------------------------------------------
  def can_repair(unit)
    return false
  end
  
end
