################################################################################
# Class Sensei
#   Army: Yellow Comet           Power Bar: x x X X X X
#
# - 130/120 Copter units
# - 120/100 Infantry/Mech units
# - +1 Move for T-Copters
# - 90/100 Vehicles and sea units
#
# Power: Copter Command
# - 150/130 Copter units
# - +1 Move for copter units (+2 for T-Copters)
#
# Super Power: Airborne Assault
# - 170/140 Copter units
# - +1 Move for copter units (+2 for T-Copters)
# - 9HP Mech Units spawn on allied cities, ready to move
# - 140/120 Infantry/Mech units
#   
################################################################################
class CO_Sensei < CO
  def initialize(army=nil)
    super(army)
    @name = "Sensei"
    @cop_name = "Copter Command"
    @scop_name = "Airborne Assault"
    @description = [
    "Yellow Comet", "Lazy Days", "Hospitals",
    "A retired paratrooper called back into action. Was rumored to be an unstoppable CO back in the days.",
    "Copter units and foot soldiers have incredible firepower. Copters have high defense and can transport units 1 space further. Weak in ground and naval combat.",
    "Copter units move an additional space further. They also have a large firepower bonus.",
      "9HP Mech units with 1 ammo spawn on cities and have their stats increased greatly for this turn. Boosts copter firepower and movement by 1.",
    "Copters and infantry have high power, but non-air units do less damage. Powers increase copter performance and spawns mech units on cities."]
    @cop_stars = 2
    @scop_stars = 6
  end
  
  def atk_bonus(unit)
    if COPTER.include?(unit.unit_type)
      if @scop or @cop
        return 150
      else
        return 130
      end
    elsif INFANTRY.include?(unit.unit_type)
      return 120
    elsif unit.move_type == MOVE_AIR
      return 100
    else
      return 90
    end
  end
  
  def def_bonus(unit)
    if COPTER.include?(unit.unit_type)
      if @scop
        return 140
      elsif @cop
        return 130
      else
        return 120
      end
    else
      if @scop
        return 120
      elsif @cop
        return 110
      else
        return 100
      end
    end
  end
  
  def move_bonus(unit)
    if unit.unit_type == TCP
      if @scop or @cop
        return 2
      else
        return 1
      end
    elsif unit.unit_type == BCP
      return 1 if (@scop or @cop)
    end
    return 0
  end
  
  def use_scop
    super
    @army.owned_props.each{|prop|
      if prop.is_a?(City) and !prop.is_a?(HQ) and !$game_map.get_unit(prop.x, prop.y).is_a?(Unit)
        unit = Mech.new(prop.x, prop.y, @army)
        unit.health = 90
        unit.ammo = 1
        unit.acted = false
        unit.add_status_effect(1)
        unit.init_sprite
        @army.add_unit(unit)
      end
    }
  end
  
end
$CO.push(CO_Sensei)