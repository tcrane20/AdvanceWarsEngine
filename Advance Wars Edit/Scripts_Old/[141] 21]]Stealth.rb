################################################################################
# Class Sub
#   Cost : 18000                Move : 5      Move Type : Water
#   Vision : 5                  Fuel : 60
#   Primary Weapon : Torps                    Ammo : 6
#   Secondary Weapon : None
################################################################################
class Stealth < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "stealth"
    @real_name = "Stealth F."
    @unit_type = 21
    @cost = 24000
    @move = 6
    @move_type = MOVE_AIR
    @vision = 4
    @max_fuel = 60
    @fuel = 60
    @fuel_cost = 5
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Omni-missiles"
    @weapon2 = ""
    @weapon1_effect = [2, 2, 2, 2, 2, 2]
    @star_energy = 200
    @can_hide = true
    @move_se = "plane"
    
    @stat_desc = ["Stealth fighters can hide itself and attack any unit.",
      "This is the unit\'s movement. It is unaffected by terrain.",
      "Stealth fighters have impressive vision.",
      "The unit burns 5 or 8 units of fuel each day. It crashes when it drops to zero.",
      "Stealth fighters are armed with missiles that can target any unit.",
      "This attack does high damage against infantry.",
      "This attack does high damage against vehicles.",
      "This attack does high damage against ships.",
      "This attack does high damage against surfaced subs.", "",
      "This attack does high damage against copters.",
      "Stealths can do high damage to all planes except fighters.", "", ""]
  end
  
  def description
    return "A silent unit that can engage any and all units."
  end
  
  #-----------------------------------------------------------------------------
  # Daily fuel cost based on if the unit is hidden or not
  #-----------------------------------------------------------------------------
  def daily_fuel_cost(officer = true)
    @fuel_cost = (@hiding ? 8 : 5)
    super
  end
  #--------------------------------------------------------------------------
  # Is it possible to attack the unit 'target'? Return true if it is.
  #--------------------------------------------------------------------------
  def can_attack?(target)
    if target.is_a?(Stealth)
      return true if (DamageChart::PriDamage[@unit_type][target.unit_type] != -1 and @ammo > 0)
    else
      return super
    end
  end
  
end
$UNITS.push(Stealth)