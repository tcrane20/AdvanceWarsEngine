################################################################################
# Class Colin
#   Army: Blue Moon           Power Bar: x x X X X X
#
# - 80% Deployment costs
# - 90/90 Units
#
# Power: Gold Rush
# - If half of current funds is less than half his daily income, multiplies
#   current funds by 1.5. Otherwise, adds half of his daily income to funds.
#
# Super Power: Power of Money
# - For every 300G, +1 offense boost for all units (cannot exceed +100 offense)
#   
################################################################################
class CO_Colin < CO
  def initialize(army=nil)
    super(army)
    @name = "Colin"
    @cop_name = "Gold Rush"
    @scop_name = "Power of Money"
    @description = [
    "Blue Moon", "Olaf, Grit, and Sasha", "Black Hole",
    "The young Blue Moon commander who is the heir to a mass fortune. Has a sharp, if insecure, mind.",
    "Being the heir to a mass fortune, Colin can buy units at lowered prices. Low firepower and defense stem from his lack of experience.",
    "Colin gains an additional 50% of daily income or multiplies his current funds by 150%, whichever is smaller.",
      "Firepower of all units increases based on the amount of funds. The more money Colin has, the more power his units receive.",
    "Rich boy-wonder. Buys units at greatly reduced costs but have low stats. Powers increase his funds and improves unit attack power."]
    @cop_stars = 2
    @scop_stars = 6
    @cost_multiplier = 80
  end
  
  def atk_bonus(unit)
    if @scop
      return 90 + ((@army.funds / 5.0)**(0.5)).to_i
    else
      return 90
    end
  end
  
  def def_bonus(unit)
    if @scop
      return 110
    elsif @cop
      return 100
    else
      return 90
    end
  end
  
  def use_cop
    super
    if @army.funds / 2 > @army.daily_income/2
      @army.funds += @army.daily_income/2
    else
      @army.funds = @army.funds * 150 / 100
    end
  end
  
end
$CO.push(CO_Colin)