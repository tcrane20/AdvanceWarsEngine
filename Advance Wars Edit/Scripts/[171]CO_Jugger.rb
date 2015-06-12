################################################################################
# Class Jugger
#   Army: Black Hole           Power Bar: x x x X X X X
#
# - Positive Luck = 0 ~ 20
# - Negative Luck = 0 ~ -10
#
# Power: Overclock
# - Positive Luck = 0 ~ 50
# - Negative Luck = 0 ~ -30
#
# Super Power: System Crash
# - Positive Luck = 0 ~ 80
# - Negative Luck = 0 ~ -50
#   
################################################################################
class CO_Jugger < CO
  def initialize(army=nil)
    super(army)
    @name = "Jugger"
    @cop_name = "Overclock"
    @scop_name = "System Crash"
    @description = [
    "Black Hole", "Computer Upgrades", "Malware",
    "",
    "The power of his units are completely random. He may do more or less damage than expected.",
    "Units may do much more damage than expected. Likewise, they may do much less damage instead.",
			"Units can do terrifying damage unexpectedly. However, they may also do almost no damage at all.",
		"Random variance in damage makes his attacks unpredictable. Powers can increase or decrease his damage significantly."]
    @cop_stars = 3
    @scop_stars = 7
  end
  
	def luck_bonus(unit)
		if @scop
			return 100
		elsif @cop
			return 60
		else
			return 30
		end
	end
	
	def neg_luck_bonus(unit)
		if @scop
			return 50
		elsif @cop
			return 30
		else
			return 15
		end
	end
  
end
$CO.push(CO_Jugger)