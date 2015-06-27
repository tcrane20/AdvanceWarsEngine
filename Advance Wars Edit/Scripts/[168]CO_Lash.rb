################################################################################
# Class Lash
#   Army: Black Hole           Power Bar: x x x x X X X
#
# - Each terrain star grants +10 offense
#
# Power: Terrain Tactics
# - Adds one more terrain defense (applies to only those with defense)
# - Perfect movement
#
# Super Power: Prime Tactics
# - Doubles terrain stars
# - Perfect movement
#   
################################################################################
class CO_Lash < CO
  def initialize(army=nil)
    super(army)
    @name = "Lash"
    @cop_name = "Terrain Tactics"
    @scop_name = "Prime Tactics"
    @description = [
    "Black Hole", "Getting her way", "Not getting her way",
    "The inventor of Black Hole's numerous weapons. Extremely intelligent despite her childish and rude mannerisms.",
    "Units use the terrain to their advantage. Offense power rises on more defensive terrains.",
    "Improves the defense of units on defensive terrain. Units can move across difficult terrain unhindered.",
      "Doubles the effects of terrain defenses, improving unit attack and defense. Units can move across difficult terrain unhindered.",
    "Terrain defenses translate into firepower bonuses for units. Powers allow perfect movement and increased stats on terrain."]
    @cop_stars = 3
    @scop_stars = 7
  end
  
  def atk_bonus(unit)
    # Get the tile unit will attack on
    if @army.playing
      tile = $game_map.get_tile($scene.decided_spot_x, $scene.decided_spot_y)
    else
      tile = $game_map.get_tile(unit.x, unit.y)
    end
    # If the tile offers terrain defense
    if tile.defense > 0 and unit.move_type != MOVE_AIR
      return (tile.defense + terrain_stars(tile)) * 10 + 100
    else
      return 100
    end
  end
  
  def terrain_stars(terrain)
    if terrain.defense > 0
      if @scop
        return terrain.defense
      end
    end
    return 0
  end
  
  def terrain_defense(tile)
    return 150 if @cop
    return 100
  end
  
  def use_cop
    super
    @perfect_movement = true
  end
  
  def use_scop
    super
    @perfect_movement = true
  end
  
  def cop=(bool)
    @cop = bool
    @perfect_movement = bool
  end
  
  def scop=(bool)
    @scop = bool
    @perfect_movement = bool
  end
  
end
$CO.push(CO_Lash)