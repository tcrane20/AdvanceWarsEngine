################################################################################
# Class Adder
#   Army: Black Hole           Power Bar: x x X X X
#
# - The rate of which the CO bar charges never decreases
#
# Power: Sideslip
# - +1 Move
#
# Super Power: Sidewinder
# - 120/120 Units
# - +2 Move
#   
################################################################################
class CO_Adder < CO
  def initialize(army=nil)
    super(army)
    @name = "Adder"
    @cop_name = "Sideslip"
    @scop_name = "Sidewinder"
    @description = [
    "Black Hole", "His Face", "Dirty Things",
    "A Black Hole commander, second to Hawke. He is extremely narcissistic, believing that his talents are matchless.",
    "Adder is quick to give actions for his units. The charge rate for his CO Powers never slows down.",
    "All units move 1 space further.",
			"All units move 2 spaces further. They also receive a firepower bonus.",
		"CO bar never slows down despite how many times it is used in battle. Powers increase the movement range of his units."]
    @cop_stars = 2
    @scop_stars = 5
  end
  
  def atk_bonus(unit)
    if @scop
      return 120
    else
      return 100
    end
  end
  
	def move_bonus(unit)
		if @scop
			return 2
		elsif @cop
			return 1
		else
			return 0
		end
	end
  
	def use_cop
		super
		@army.recharge_rate = 100
	end
	
	def use_scop
		super
		@army.recharge_rate = 100
	end
end
$CO.push(CO_Adder)