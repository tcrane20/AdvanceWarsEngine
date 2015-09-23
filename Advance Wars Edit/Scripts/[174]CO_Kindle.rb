################################################################################
# Class Kindle
#   Army: Black Hole           Power Bar: x x x X X X
#
# - +20 offense when attacking on properties
# - Terrain defense offers half defense bonus
#
# Power: Urban Blight
# - 3 HP Mass damage to units on cities
# - +40 offense when attacking on properties
#
# Super Power: High Society
# - +3 offense per property owned
# - +60 offense when attacking on properties
#   
################################################################################
class CO_Kindle < CO
  def initialize(army=nil)
    super(army)
    @name = "Kindle"
    @cop_name = "Urban Blight"
    @scop_name = "High Society"
    @description = [
      "Black Hole", "Anything Chic", "Anything Passé",
      "",
      "Being from the cities, units do more damage when attacking on properties. Her units have difficulty utilizing the terrain for full defenses.",
      "Enemy units on properties take 3 HP damage. Firepower rises when attacking on properties.",
      "Firepower rises based on the number of properties Kindle owns. Firepower greatly rises when attacking on properties.",
    "Units on properties do more damage. Defense bonuses from terrain is reduced. Powers can damage enemy units and increase the firepower of her units."]
    @cop_stars = 3
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
    atk = 100
    # Define property bonus
    if @army.playing
      tile = $game_map.get_tile($scene.decided_spot_x, $scene.decided_spot_y)
    else
      tile = $game_map.get_tile(unit.x, unit.y)
    end
    if tile.is_a?(Property)
      if @scop
        atk += 60
      elsif @cop
        atk += 40
      else
        atk += 20
      end
    end
    if @scop
      atk += (@army.owned_props.size * 3)
    end
    return atk
  end
  
  def terrain_defense(tile)
    return 50
  end
  
  def use_cop
    super
    ($game_map.units - @army.units).each{|unit|
      unit.injure(30, false, false) if $game_map.get_tile(unit.x, unit.y).is_a?(Property)
    }
  end
  
  
end
$CO.push(CO_Kindle)