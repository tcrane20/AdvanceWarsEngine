################################################################################
# Class Andy
#   Army: Orange Star           Power Bar: x x x X X X
#
# - 100/100 Units
#
# Power: Hyper Repair
# - All units are healed 2 HP
# - 110/110 Units
#
# Super Power: Hyper Upgrade
# - All units are healed 5 HP
# - 120/120 Units
# - Direct Combat +1 Move
# - Indirect Combat +1 Range
#   
################################################################################
class CO_Andy < CO
  def initialize(army=nil)
    super(army)
    @name = "Andy"
    @cop_name = "Hyper Repair"
    @scop_name = "Hyper Upgrade"
    @description = [
    "Orange Star", "Fixing stuff", "Getting up early",
    "A young, whimsical boy-wonder who is quite knowledgeable with machines. He saved Macro Land from the last great invasion.",
    "Andy has no preferences over units. He is good with all of them, ready wherever, whenever.",
    "All units restore 2 HP. They also receive a firepower boost.",
		"All units restore 5 HP. Firepower of units increases. Direct combat move 1 space further while indirect combat can fire 1 space further.",
		"The Orange Star mechanic. Prefers no unit over another. Powers allow him to heal units and increase their damage."]
    @cop_stars = 3
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
    if @scop or @cop
      return 120
    else
      return 100
    end
  end
  
	def move_bonus(unit)
		if @scop and unit.max_range(false) <= 1
			return 1
		else
			return 0
		end
	end
	
	def range_bonus(unit)
		if @scop and unit.max_range(false) > 1
			return 1
		else
			return 0
		end
	end
	
  def use_cop
    super
    mass_heal(2, @army.units)
  end
  
  def use_scop
    super
    @army.units.each{|unit|
      next if unit.loaded
      proc = Proc.new{ unit.repair(5); unit.sprite.play_animation('super_0')}
      $game_player.add_move_action(unit.x, unit.y, proc, WAIT_UNIT_POWER)
    }
  end
end
$CO.push(CO_Andy)