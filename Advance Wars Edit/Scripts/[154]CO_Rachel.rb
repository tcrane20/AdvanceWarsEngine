################################################################################
# Class Rachel
#   Army: Orange Star           Power Bar: x x x X X X
#
# - Repairs 3 HP on cities (must pay for these costs)
# - 110/100 Units that made repairs this day
#
# Power: Lucky Lass
# - Base Luck = 20
# - Enemy attacks may do 0 ~ 5 less damage
#
# Super Power: Covering Fire
# - Allows the user to target a radius 3 square, doing 3 HP damage to all the
#   units in the affected area and reducing the defenses of these units by 20
#   
################################################################################
class CO_Rachel < CO
  def initialize(army=nil)
    super(army)
    @name = "Rachel"
    @cop_name = "Lucky Lass"
    @scop_name = "Covering Fire"
    @description = [
      "Orange Star", "Spirited COs", "",
      "Nell's younger sister. A happy-go-lucky individual who believes that determination and optimism make the best COs.",
      "Units repair faster, healing an extra HP. Units that made repairs gain a slight boost in power.",
      "Attacks may do more damage than expected. Enemy attacks may do less damage than expected.",
      "Fires a large missile that deals 3 HP damage to all units in range. Hit units have their defenses reduced during her turn.",
      "Commanded the Allied Nations. Repairs units faster and improves their damage. Powers enhance luck damage and fire a missile on enemy targets."]
    @cop_stars = 3
    @scop_stars = 6
    @repair = 3
  end
  
  def atk_bonus(unit)
    return 110 if unit.made_repairs
    return 100
  end
  
  def luck_bonus(unit)
    if @cop
      return 25
    else
      return 5
    end
  end
  
  def def_luck_bonus(unit)
    if @cop
      return 10
    else
      return 0
    end
  end
  
  def use_scop
    super
    # Find best missile spot
    loc = $scene.find_best_missile_spot(3)
    # Get all the spots where this missile hits
    positions = $game_map.get_spaces_in_area(loc[0],loc[1],3)
    positions.each{|pos|
      # Get unit at this spot
      u = $game_map.get_unit(pos[0],pos[1])
      next if u.nil?
      # Damage it and apply status effect
      u.injure(30, false, false)
      u.add_status_effect(0)
    }
    $game_player.moveto(loc[0],loc[1], true)
  end
end
$CO.push(CO_Rachel)