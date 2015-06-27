################################################################################
# Class Eagle
#   Army: Green Earth           Power Bar: x x x x x X X X X
#
# - 115/115 Air units
# - Air units burn 3 less fuel daily
# - 80/80 Sea units
#
# Power: Lightning Drive
# - All air units that have carried out an action may move again
#
# Super Power: Lightning Strike
# - All non-infantry units that have carried out an action may move again
# - 130/130 Air units
#   
################################################################################
class CO_Eagle < CO
  def initialize(army=nil)
    super(army)
    @name = "Eagle"
    @cop_name = "Lightning Drive"
    @scop_name = "Lightning Strike"
    @description = [
      "Green Earth", "Lucky Goggles", "Swimming",
      "Green Earth's airforce commander. He became a pilot to follow his father's legacy.",
      "Being a superb pilot, air units have improved offense and defense. They also burn less fuel each day. Sea units are extremely weak.",
      "All non-infantry units that have carried out orders may move again. Firepower is reduced during his turn.",
      "All non-infantry units that have carried out orders may move again.",
    "Air units have improved stats while sea units are weak. Powers allow units to carry out orders again, moving and attacking twice in one day."]
    @cop_stars = 5
    @scop_stars = 9
  end
  
  def atk_bonus(unit)
    case unit.move_type
    when MOVE_AIR then return (@cop && @army.playing ? 60 : 120)
    when MOVE_SEA,MOVE_TRANS then return (@cop && @army.playing ? 35 : 70)
    end
    return (@cop && @army.playing ? 50 : 100)
  end
  
  def def_bonus(unit)
    case unit.move_type
    when MOVE_AIR 
      if @scop
        return 140
      elsif @cop
        return 130
      else
        return 120
      end
    when MOVE_SEA,MOVE_TRANS
      if @scop
        return 90
      elsif @cop
        return 80
      else
        return 70
      end
    end
    if @scop
      return 120
    elsif @cop
      return 110
    else
      return 100
    end
    
  end
  
  def fuel_burn_bonus(unit)
    if unit.move_type == MOVE_AIR
      return -2
    end
    return 0
  end
  
  
  def use_cop
    super
    @army.units.each{|u| u.acted = false unless INFANTRY.include?(u.unit_type)}
  end
  
  def use_scop
    super
    @army.units.each{|u| u.acted = false unless INFANTRY.include?(u.unit_type)}
  end
  
end
$CO.push(CO_Eagle)