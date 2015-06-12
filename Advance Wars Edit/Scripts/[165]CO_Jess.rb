################################################################################
# Class Jess
#   Army: Green Earth           Power Bar: x x x X X X
#
# - 115/100 non-Infantry land units
# - 90/100 for other units
#
# Power: Turbo Charge
# - 130/120 non-Infantry land units
# - +1 Move for non-Infantry land units
# - Resupplies all units
#
# Super Power: Overdrive
# - 150/130 non-Infantry land units
# - +2 Move for non-Infantry land units
# - Resupplies all units
#   
################################################################################
class CO_Jess < CO
  def initialize(army=nil)
    super(army)
    @name = "Jess"
    @cop_name = "Turbo Charge"
    @scop_name = "Overdrive"
    @description = [
    "Green Earth", "Dandelions", "Unfit COs",
    "Green Earth's calm and cool tactician. She never acts without knowing what lies ahead.",
    "Excellent in land battles. Vehicles gain a boost in firepower. Infantry, air, and sea units are weaker in comparison.",
    "Vehicles gain a firepower bonus and move 1 space further. All units receive full supplies.",
			"Vehicles gain a larger firepower bonus and move 2 spaces further. All units receive full supplies.",
		"Vehicle units have higher firepower, but all other units are weaker. Powers increase vehicle stats while giving full supplies to all units."]
    @cop_stars = 3
    @scop_stars = 6
  end
	
	def atk_bonus(unit)
		if VEHICLE.include?(unit.unit_type)
			if @scop
				return 150
			elsif @cop
				return 130
			else
				return 115
			end
		else
			return 90
		end
	end
	
	def move_bonus(unit)
		if VEHICLE.include?(unit.unit_type)
			return 2 if @scop
			return 1 if @cop
		end
		return 0
	end
	
	def use_cop
		super
		full_supplies(@army.units)
	end
	
	def use_scop
		super
		full_supplies(@army.units)
	end
  
end
$CO.push(CO_Jess)