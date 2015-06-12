################################################################################
# Class Nell
#   Army: Orange Star           Power Bar: x x x X X X
#
# - Base Luck = 15
#
# Power: Lucky Star
# - Base Luck = 30
#
# Super Power: Lady Luck
# - Base Luck = 50
#   
################################################################################
class CO_Nell < CO
  def initialize(army=nil)
    super(army)
    @name = "Nell"
    @cop_name = "Lucky Star"
    @scop_name = "Lady Luck"
    @description = [
    "Orange Star", "Willfull students", "Downtime",
    "Rachel's older sister and supreme commander of Orange Star. Knowledgable and kind-hearted, she is a well respected officer.",
    "Units may do more damage than expected. She will be the first to tell you she was born lucky.",
    "Units may do even more damage than expected. Lucky!",
			"Units may do a ton more damage than expected. Very lucky!",
		"Orange Star\'s lead commander. Units have increased luck, doing more damage at times. Powers improve the amount of luck units receive."]
    @cop_stars = 3
    @scop_stars = 6
  end
	
	def luck_bonus(unit)
		if @scop
			return 50
		elsif @cop
			return 30
		else
			return 15
		end
	end
  
end
$CO.push(CO_Nell)