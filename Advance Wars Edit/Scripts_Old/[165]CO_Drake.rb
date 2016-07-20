################################################################################
# Class Drake
#   Army: Green Earth           Power Bar: x x x x X X X
#
# - 110/120 Sea units
# - +1 Move for Landers
# - 80/80 Air units
# - Unaffected by rain penalties
#
# Power: Tsunami
# - 1 HP Mass Damage
# - Halves enemy fuel
#
# Super Power: Typhoon
# - 2 HP Mass Damage
# - Halves enemy fuel
# - 2 day rain
#   
################################################################################
class CO_Drake < CO
  def initialize(army=nil)
    super(army)
    @name = "Drake"
    @cop_name = "Tsunami"
    @scop_name = "Typhoon"
    @description = [
      "Green Earth", "Surfing", "High Places",
      "",
      "Naval units have impressive offense and defense. Landers move 1 space further. His troops are unaffected by the rain. Air units are severly weakened.",
      "Damages all enemy units by 1 HP. Their fuel is cut in half. Causes rain for 1 day.",
      "Damages all enemy units by 2 HP. Their fuel is cut in half. Causes rain for 2 days.",
    "Sea units have increased firepower and defenses but air units are weak. Unaffected by rain. Powers cause rain, deal damage, and reduce enemy fuel."]
    @cop_stars = 4
    @scop_stars = 7
    @no_rain_penalty = true
  end
  
  def atk_bonus(unit)
    case unit.move_type
    when MOVE_AIR then return 70
    when MOVE_SEA,MOVE_TRANS then return 120
    end
    return 100
  end
  
  def def_bonus(unit)
    case unit.move_type
    when MOVE_AIR 
      if @scop
        return 90
      elsif @cop
        return 80
      else
        return 70
      end
    when MOVE_SEA,MOVE_TRANS
      if @scop
        return 140
      elsif @cop
        return 130
      else
        return 120
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
  
  def move_bonus(unit)
    if unit.unit_type == LND
      return 1
    else
      return 0
    end
  end
  
  def use_cop
    super
    $game_map.set_weather('rain', 1)
    mass_damage(1, $game_map.units - @army.units)
    cut_fuel($game_map.units - @army.units, 2)
  end
  
  def use_scop
    super
    $game_map.set_weather('rain', 2)
    mass_damage(2, $game_map.units - @army.units)
    cut_fuel($game_map.units - @army.units, 2)
  end
end
$CO.push(CO_Drake)