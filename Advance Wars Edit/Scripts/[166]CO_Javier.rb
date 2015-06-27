################################################################################
# Class Javier
#   Army: Green Earth           Power Bar: x x x X X X
#
# - 100/120 Units against indirect attacks
# - +10 defense boost for each captured COM Tower
#
# Power: Tower Guard
# - 100/200 Units against indirect attacks
# - Doubles COM Tower effects
#
# Super Power: Tower of Power
# - 100/300 Units against indirect attacks
# - Triples COM Tower effects
#   
################################################################################
class CO_Javier < CO
  def initialize(army=nil)
    super(army)
    @name = "Javier"
    @cop_name = "Tower Shield"
    @scop_name = "Tower of Power"
    @description = [
    "Green Earth", "Chivalry", "Retreating",
    "",
    "A master of communication, COM Towers give defense bonuses to his units. Units have high defense against indirect units. Secondary weapons are weaker.",
    "Doubles the defense boost of COM Towers. Damage received from indirect fire is halved.",
      "Doubles the effects of COM Towers. Damage received from indirect fire is reduced to a third.",
    "Towers provide defense boosts to his units. Increased indirect-fire resistance but weaker secondary weapons. Powers improve COM Tower effects and defense."]
    @cop_stars = 3
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
    if unit.weapon_use == 1 # If primary weapon attack
      if @scop
        return 100 + @army.num_of_property(ComTower) * 10
      else
        return 100
      end
    else # Secondary weapon attack
      if @scop
        return 90 + @army.num_of_property(ComTower) * 10
      else
        return 90
      end
    end
  end
  
  def def_bonus(unit)
    total = 100
    # Defense bonus from COM towers
    if @scop
      total += (@army.num_of_property(ComTower) * 20) + 20
    elsif @cop
      total += (@army.num_of_property(ComTower) * 20) + 10
    else
      total += @army.num_of_property(ComTower) * 10
    end
    # Determine if being attacked from indirect unit
    if !@army.playing
      enemy = $scene.unit
      if enemy.max_range > 1
        total += 20
        total += 80 if @cop
        total += 180 if @scop
      end
    end
    return total
  end
  
end
$CO.push(CO_Javier)