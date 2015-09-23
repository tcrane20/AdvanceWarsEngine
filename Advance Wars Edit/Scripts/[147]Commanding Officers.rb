=begin
___________
 CO        \____________________________________________________________________
 
 The commanding officer. Each CO is a child of this class. This holds all the
 default values for an officer. Contains some variables and configuration
 methods any new officer could possibly use.
 
 Notes:
 * Remove floats
 * Document things better
 
 Updates:
 - 11/02/14
   + At the end of every officer class, you must push it into the $CO array
________________________________________________________________________________
=end
class CO
  attr_accessor :name
  attr_accessor :cop
  attr_accessor :scop
  attr_accessor :cop_name
  attr_accessor :scop_name
  attr_accessor :cop_stars
  attr_accessor :scop_stars
  attr_accessor :description
  attr_accessor :repair
  attr_accessor :cost_multiplier
  attr_accessor :no_snow_penalty, :no_rain_penalty, :no_sand_penalty
  attr_accessor :no_luck_penalty
  attr_accessor :build_on_cities      # Can buy units off cities
  attr_reader :pierce_fow              # Can see through thick terrain in FOW
  attr_reader :perfect_movement        # Units move unhindered
  attr_reader :income_multiplier      # Multiplies income by this amount
  attr_reader :gain_dmg_as_funds      # Gain money based on damage inflicted
  attr_reader :first_counter          # Units counter attack first
  attr_reader :hide_hp                # Unit HP is hidden from enemy view
  attr_reader :last_stand
  
  def initialize(army=nil)
    @name = ""
    @cop = false
    @scop = false
    @cop_name = ""
    @scop_name = ""
    @description = []
    @cop_stars = 0
    @scop_stars = 0
    @army = army
    
    # Define bonus effects that COs may have
    
    @repair = 2
    @income_multiplier = 1
    @cost_multiplier = 100
    @no_snow_penalty, @no_rain_penalty, @no_sand_penalty = false, false, false
    @no_luck_penalty = false
    @build_on_cities = false
    @perfect_movement = false
    @pierce_fow  = false
    @last_stand = false
  end
  
  def nation
    return @description[0]
  end
  
  
  def cop_rate
    return @cop_stars * 100
  end
  
  def scop_rate
    return @scop_stars * 100
  end
  
  def atk_bonus(unit)
    return 100
  end
  
  def def_bonus(unit)
    if @scop
      return 120
    elsif @cop
      return 110
    else
      return 100
    end
  end
  
  def luck_bonus(unit)
    return 5
  end
  
  def neg_luck_bonus(unit)
    return 0
  end
  
  def def_luck_bonus(unit)
    return 0
  end
  
  def fuel_burn_bonus(unit)
    return 0
  end
  
  def move_bonus(unit)
    return 0
  end
  
  def vision_bonus(unit)
    return 0
  end
  
  def range_bonus(unit)
    return 0
  end
  
  def capt_bonus
    return ["add", 0]
  end
  
  def terrain_stars(tile)
    return 0
  end
  
  def terrain_defense(tile)
    return 100
  end
  
  def cost_mult(unit)
    return unit.cost * @cost_multiplier
  end
  
  def use_cop
    @cop = true
  end
  
  def use_scop
    @scop = true
  end
  
  def mass_heal(hp, units)
    units.each{|unit| 
      next if unit.loaded
      unit.repair(hp)
    }
  end
  
  def mass_damage(hp, units)
    units.each{|unit| 
      next if unit.loaded
      unit.injure(hp*10, false, false)
    }
  end
  
  def inc_vision(plus_vision, units)
    units.each{|unit| unit.vision += plus_vision}
  end
  
  def full_supplies(units, not_fuel=false, not_ammo=false)
    units.each{|unit|
      next if unit.loaded
      unit.fuel = unit.max_fuel unless not_fuel
      unit.ammo = unit.max_ammo unless not_ammo
    }
  end
  
  def cut_fuel(units, amount)
    units.each{|unit|
      next if unit.loaded
      unit.fuel /= amount
    }
  end
  
  def summon_snow(days)
  end
  
  def summon_rain(days)
  end
  
  
  
  
end