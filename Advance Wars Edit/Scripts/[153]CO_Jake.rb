################################################################################
# Class Jake
#   Army: Orange Star           Power Bar: x x x X X X
#
# - +10 offense on plains
# - 110/100 Tank units
#
# Power: Beat Down
# - +30 offense on plains
# - +1 Range for ground indirect combat units
#
# Super Power: Block Rock
# - +40 offense on plains
# - 120/120 Tank units
# - +2 Move for non-Infantry ground units
# - +1 Range for ground indirect combat units
#   
################################################################################
class CO_Jake < CO
  def initialize(army=nil)
    super(army)
    @name = "Jake"
    @cop_name = "Beat Down"
    @scop_name = "Block Rock"
    @description = [
    "Orange Star", "Jamming", "Easy Listening",
    "A young commander-in-training. He was raised from the streets but his outgoing personality hides his past.",
    "Fights well in the open. Units do more damage when attacking on plains. Tanks have a slight power boost.",
    "Units do more damage when attacking on plains. Indirect ground units can fire 1 space further.",
      "Units do even more damage when attacking on plains. Tanks gain a power boost. Vehicles move 2 spaces further. Indirect ground units can fire 1 space further.",
    "Tank enthusiast. Units do more damage on plains. Tanks have high firepower. Powers enhance vehicles and further improve his damage on plains."]
    @cop_stars = 3
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
    atk = 100
    # Define plains bonus
    if @army.playing
      tile = $game_map.get_tile($scene.decided_spot_x, $scene.decided_spot_y)
    else
      tile = $game_map.get_tile(unit.x, unit.y)
    end
    if tile.is_a?(Plains)
      if @scop
        atk += 40
      elsif @cop
        atk += 30
      else
        atk += 10
      end
    end
    # Define tank bonus
    if TANK.include?(unit.unit_type)
      if @scop
        atk += 20
      else
        atk += 10
      end
    end
    return atk
  end
  
  def move_bonus(unit)
    return 0 unless @scop
    if VEHICLE.include?(unit.unit_type)
      return 2
    end
    return 0
  end
  
  def range_bonus(unit)
    return 0 unless @cop or @scop
    if [ART, MIS, RKT, ATK].include?(unit.unit_type)
      return 1
    end
    return 0
  end
  
end
$CO.push(CO_Jake)