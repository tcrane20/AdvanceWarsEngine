################################################################################
# Class Sami
#   Army: Orange Star           Power Bar: x x x X X X X X
#
# - 130/100 Infantry Units
# - 1.25x Capture rate (12, 11, 10, 8, 7, 6, 5, 3, 2, 1)
# - 90/100 direct combat Units
#
# Power: Double Time
# - 150/110 Infantry Units
# - +1 Move for Infantry and Transport Units
# - 1.5x Capture rate (15, 13, 12, 10, 9, 7, 6, 4, 3, 1)
#
# Super Power: Victory March
# - 180/120 Infantry Units
# - +2 Move for Infantry Units
# - 3x Capture rate (20, 20, 20, 20, 20, 20, 16, 12, 8, 4)
#   
################################################################################
class CO_Sami < CO
  def initialize(army=nil)
    super(army)
    @name = "Sami"
    @cop_name = "Double Time"
    @scop_name = "Victory March"
    @description = [
    "Orange Star", "Chocolate", "Cowards",
    "A special forces captain who is loyal to her nation. Very level-headed even in the midst of serious danger.",
    "Infantry units have superior firepower. They also capture properties faster. Shoddy in non-infantry direct combat.",
    "Infantry units gain more firepower and capture faster. Foot soldiers and transport units move 1 space further.",
			"Infantry units have massive firepower and have their capture speeds quadrupled. Foot soldiers move 2 spaces further.",
		"Infantry specialist. Soldiers have high attack and capture rates. Weak direct-combat units. Powers improve infantry attack, movement, and capture rates."]
    @cop_stars = 3
    @scop_stars = 8
  end
	
	def atk_bonus(unit)
		if INFANTRY.include?(unit.unit_type)
			if @scop
				return 180
			elsif @cop
				return 160
			else 
				return 130
			end
		end
		return 90 if unit.max_range(false) == 1
    return 100
  end
	
	def move_bonus(unit)
		if [MOVE_FOOT, MOVE_MECH].include?(unit.move_type)
			if @scop
				return 2
			elsif @cop
				return 1
			end
		elsif TRANSPORT.include?(unit.unit_type)
			return 1 if @cop
		end
		return 0
	end
	
	def capt_bonus
		if @scop
			return ["mult", 400]
		elsif @cop
			return ["mult", 150]
		else
			return ["mult", 125]
		end
	end
  
end
$CO.push(CO_Sami)