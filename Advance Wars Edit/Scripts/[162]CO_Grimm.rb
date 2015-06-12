################################################################################
# Class Grimm
#   Army: Yellow Comet           Power Bar: x x x X X X
#
# - 130/90 Units
# - 120/80 Units during other player turns
#
# Power: Knuckle Duster
# - 160/90 Units
# - 140/80 Units during other player turns
#
# Super Power: Haymaker
# - 200/90 Units
# - 160/80 Units during other player turns
#   
################################################################################
class CO_Grimm < CO
  def initialize(army=nil)
    super(army)
    @name = "Grimm"
    @cop_name = "Knuckle Duster"
    @scop_name = "Haymaker"
    @description = [
    "Yellow Comet", "Donuts", "Chit chat",
    "Nicknamed \"Lightning Grimm\". He is always eager to fight. Could care less about the details.",
    "Being a man of action, Grimm has superior firepower only during his turn. Unit defense lowers during other CO's turns.",
    "Raises the firepower of units during Grimm's turn. Units receive no defense bonus.",
    "Greatly raises the firepower of units during Grimm's turn. Units receive no defense bonus.",
		"Units have very high firepower during his turn. Low defense stat. Powers further increase the firepower of his units."]
    @cop_stars = 3
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
		# If player's turn
		if @army.playing
			if @scop
				return 180
			elsif @cop
				return 150
			else
				return 130
			end
		else
			return 100
		end
  end
  
	def def_bonus(unit)
		# If player's turn
		if @army.playing
			return 100
		else
			return 90
		end
	end
  
end
$CO.push(CO_Grimm)