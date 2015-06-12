################################################################################
# Class Sasha
#   Army: Blue Moon           Power Bar: x x X X X X
#
# - 1.1x funds received from properties
# - Gains more luck with more money (find formula)
#
# Power: Market Crash
# - Reduces enemy CO bars (10,000G = 1 Star)
# - Halves funds received by enemy next turn
#
# Super Power: War Bonds
# - Gains half of inflicted damage as funds
#   
################################################################################
class CO_Sasha < CO
	def initialize(army=nil)
    super(army)
    @name = "Sasha"
    @cop_name = "Market Crash"
    @scop_name = "War Bonds"
    @description = [
    "Blue Moon", "Truffles", "Pork Rinds",
    "Colin's older sister. She becomes more daring when she gets angry.",
    "Daily funds are increased by 10 percent. Her units may do more damage depending on how much money she holds.",
    "Reduces enemy CO bars based on the amount of funds Sasha has. Enemy armies also receive only half of their daily income on their next turn.",
			"Gains half of the inflicted damage her units do as funds.",
		"Colin\'s rich sister. Receives more daily income which increases her luck. Powers reduce enemy CO bars and increase her funds."]
    @cop_stars = 3
    @scop_stars = 6
		@income_multiplier = 110
  end
	
	def luck_bonus(unit)
		return [5 + @army.funds / 3000, 25].min
	end
  
	def use_cop
		super
		($game_map.army - [@army]).each{|army|
			army.stored_energy -= army.officer.scop_rate * @army.funds / 50000
			army.halve_income = true
		}
	end
	
	def use_scop
		super
		@gain_dmg_as_funds = true
	end
	
  def scop=(bool)
		@scop = bool
		@gain_dmg_as_funds = false
	end
	
end
$CO.push(CO_Sasha)