################################################################################
# Class Flak
#   Army: Black Hole           Power Bar: x x x X X X
#
# - 120/100 Units
# - Base Luck = -10 ~ 0
#
# Power: Brute Force
# - 150/110 Units
# - Base Luck = -20 ~ 0
#
# Super Power: Barbaric Blow
# - 180/120 Units
# - Base Luck = -30 ~ 0
#   
################################################################################
class CO_Flak < CO
  def initialize(army=nil)
    super(army)
    @name = "Flak"
    @cop_name = "Brute Force"
    @scop_name = "Barbaric Blow"
    @description = [
    "Black Hole", "Meat", "Veggies",
    "",
    "Units have very high firepower. Due to Flak's relentless nature, their attacks usually do less damage than expected.",
    "Further boosts the power of his units. However, they are more likely to do less damage than expected.",
      "Dramatically increases the firepower of his units. However, they are much more likely to do less damage than expected.",
    "All units have high attack. Negative luck may reduce the damage his units are capable of. Powers boost firepower but increases the chance of negative luck."]
    @cop_stars = 3
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
    if @scop
      return 190
    elsif @cop
      return 160
    else
      return 120
    end
  end
  
  def luck_bonus(unit)
    return 5
  end
  
  def neg_luck_bonus(unit)
    if @scop
      return 30
    elsif @cop
      return 20
    else
      return 10
    end
  end
  
end
$CO.push(CO_Flak)