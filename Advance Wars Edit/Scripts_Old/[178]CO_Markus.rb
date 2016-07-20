################################################################################
# Class Markus
#   Army: White Nova          Power Bar: x x x X X X
#
# - Power of units equals 1.05^(10 - HP)
# - 120/100 Counters
#
# Power: New Hope
# - Additional Luck bonus based on HP (5 + (10 - HP))
# - Luck does not drop with HP
# - 140/110 Counters
#
# Super Power: Burning Will
# - Power of units equals 1.1^(10 - HP)
# - 150/120 Counters
#   
################################################################################
class CO_Markus < CO
  def initialize(army=nil)
    super(army)
    @name = "Markus"
    @cop_name = "New Hope"
    @scop_name = "Burning Will"
    @description = [
    "Orange Star", "Confidence", "Bullies",
    "A strong-hearted individual who encourages others around him to stand. His speeches are remarkable.",
    "Never the one to back down, unit firepower decreases slowly as HP decreases. Counters are stronger.",
    "Luck of units increases based on the amount of HP they lost. Counters deal more damage.",
    "Further boosts the firepower and defense of damaged units. Improves counter attack damage further.",
    "Damaged units are not severly penalized compared to other COs and have strong counters. Powers further improve these effects."]
    @cop_stars = 3
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
    bonus = 0
    if @scop
      bonus += (1.1 ** (10 - unit.unit_hp)) * 100
    else
      bonus += (1.05 ** (10 - unit.unit_hp)) * 100
    end
    bonus = bonus.to_i
    if !@army.playing
      if @scop
        bonus += 50
      elsif @cop
        bonus += 40
      else
        bonus += 20
      end
    end
    return bonus
  end
  
  def def_bonus(unit)
    bonus = 0
    if @scop
      bonus += (1.1 ** (10 - unit.unit_hp)) * 100
      return bonus.to_i + 20
    elsif @cop
      return 110
    else
      return 100
    end
  end
  
  def luck_bonus(unit)
    if @cop
      return 6 + (10 - unit.unit_hp)
    else
      return 5
    end
  end
  
  def use_cop
    super
    @no_luck_penalty = true
  end
  
  def cop=(bool)
    @cop = bool
    @no_luck_penalty = bool
  end
  
  
end
$CO.push(CO_Markus)