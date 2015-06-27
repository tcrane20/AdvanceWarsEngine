################################################################################
# Class Max
#   Army: Orange Star           Power Bar: x x x X X X
#
# - 120/100 non-INF direct combat Units
# - 90/100 and -1 max range for indirect combat Units
#
# Power: Max Force
# - 140/110 non-INF direct combat Units
# - +1 Move for non-INF direct combat Units
#
# Super Power: Max Blast
# - 180/120 non-INF direct combat Units
#   
################################################################################
class CO_Max < CO
  def initialize(army=nil)
    super(army)
    @name = "Max"
    @cop_name = "Max Force"
    @scop_name = "Max Blast"
    @description = [
      "Orange Star", "Working Out", "Studying",
      "A loyal officer who is never afraid to back away from a fight. He enjoys a good old-fashioned beat down.",
      "Non-infantry direct combat units gain an offensive boost. Indirect units are weaker and fire one space shorter.",
      "Non-infantry direct combat units gain more power. They also move 1 space further.",
      "Non-infantry direct combat units have superior firepower and move 1 space further.",
      "Prefers direct-combat units over indirect-combat units. Powers increase their damage and movement."]
    @cop_stars = 3
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
    if unit.max_range(false) == 1
      # Direct non infantry units
      if !INFANTRY.include?(unit.unit_type)
        if @scop
          return 170
        elsif @cop
          return 140
        else
          return 120
        end
      else
        # Infantry / Mech
        return 100
      end
    else
      # Indirect unit
      return 70#80
    end
  end
  
  def move_bonus(unit)
    if (@cop or @scop) and unit.max_range(false) == 1 and !INFANTRY.include?(unit.unit_type)
      return 1
    end
    return 0
  end
  
#  def range_bonus(unit)
#    if unit.max_range(false) > 1
#      return -1
#    end
#    return 0
#  end
end
$CO.push(CO_Max)