#============================================================================
# Stores all data for each type of terrain. Each tile on the map is initialized
# and stored in a Table in the Map Data.
#============================================================================
class Tile
  attr_accessor :name, :id, :defense, :fow_cover, :vision
  #-------------------------------------------------------------------------
  #  Initialize the tile properties. This method should be extended in each
  # Tile class. Using 'super' will default properties to these values below.
  #-------------------------------------------------------------------------
  def initialize(*args)
    @name = ''          # Name of the tile, as shown in-game
    @id = 0             # Identifier; recommended to create constants for each tile
    @defense = 0        # How many terrain stars this tile provides
    @fow_cover = false  # Does this tile remain hidden in FOW until a unit is next to it?
    @vision = 0         # How many spaces away this tile reveals in FOW
  end
  #-------------------------------------------------------------------------
  #  Assigns the move chart for each type of unit transport. Please follow
  # this structure when redefining this method in other Tile classes.
  #-------------------------------------------------------------------------
  def move_cost_chart(move_type)
    return case move_type         # Normal  Snow  Rain
    when MOVE_FOOT then return    [ 1]
    when MOVE_MECH then return    [ 1]
    when MOVE_TIRE then return    [ 1]
    when MOVE_TREAD then return   [ 1]
    when MOVE_AIR then return     [ 1,      2]
    when MOVE_TRANS then return   [ 0]
    when MOVE_SEA then return     [ 0]
    when MOVE_TIRE_B then return  [ 1]
    end
  end
  #-------------------------------------------------------------------------
  #  This tile offers a bonus to the unit's vision range.
  #-------------------------------------------------------------------------
  def fow_bonus(unit)
    return 0
  end
  #-------------------------------------------------------------------------
  #  Checks if the specified unit can be repaired on this tile.
  #-------------------------------------------------------------------------
  def can_repair(unit)
    return false
  end
  #-------------------------------------------------------------------------
  #  Gets the move cost for this unit. Factors in weather and CO abilities.
  # This is the parent method; it does not require a rewrite in every Tile-
  # based class.
  #-------------------------------------------------------------------------
  def move_cost(unit)
    # Get the move chart (convert to an array if necessary, to prevent errors below)
    cost = Array(move_cost_chart(unit.move_type))
    # If perfect movement, then 1 (unless can't move on tile normally)
    if unit.co.perfect_movement and cost[0] != 0
      return 1
    # Weather is snow, or the CO moves in the rain as if it were snow
    elsif ($game_map.current_weather == 'snow' and !unit.co.no_snow_penalty) or
    ($game_map.current_weather == 'rain' and unit.co.rain_is_snow)
      # If no snow cost is assigned, then use normal cost
      return cost[1].nil? ? cost[0] : cost[1]
    elsif $game_map.current_weather == 'rain' and !unit.co.no_rain_penalty
      # If no rain cost is assigned, then use normal cost
      return cost[2].nil? ? cost[0] : cost[2]
    else
      return cost[0]
    end
  end
end