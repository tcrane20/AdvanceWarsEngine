################################################################################
# Class Sub
#   Cost : 18000                Move : 5      Move Type : Water
#   Vision : 5                  Fuel : 60
#   Primary Weapon : Torps                    Ammo : 6
#   Secondary Weapon : None
################################################################################
class Sub < Unit
  def initialize(*args)
    super(*args)
    @name = "sub"
    @real_name = "Submarine"
    @unit_type = 17
    @cost = 20000
    @move = 5
    @move_type = 6
    @vision = 5
    @max_fuel = 60
    @fuel = 60
    @fuel_cost = 1
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Torps"
    @weapon1_effect = [0, 0, 2, 2, 0, 0]
    @star_energy = 150
    @can_dive = true
    @move_se = "ship"
    
    @stat_desc = ["Submarines can hide underwater and attack unsuspecting ships.",
      "This is the unit\'s movement. It can only move across the sea.",
      "Submarines can see far distances in Fog of War.",
      "The unit burns 1 or 5 units of fuel each day. It sinks when it drops to zero.",
      "Subs attack with torpedoes against ship units.",
      "Subs do high damage to all ships except cruisers.",
      "Subs can attack other hidden subs for good damage.", "", "",
      "Submarines can no longer attack when they run out of ammo.", "", "","", ""]
  end
  
  def description
    return "A silent unit that hides underwater before attacking."
  end
  
  #-----------------------------------------------------------------------------
  # Daily fuel cost based on if the unit is hidden or not
  #-----------------------------------------------------------------------------
  def daily_fuel_cost(officer = true)
    @fuel_cost = (@hiding ? 5 : 1)
    super
  end
  #--------------------------------------------------------------------------
  # Is it possible to attack the unit 'target'? Return true if it is.
  #--------------------------------------------------------------------------
  def can_attack?(target)
    if target.is_a?(Sub)
      return true if (DamageChart::PriDamage[@unit_type][target.unit_type] != -1 and @ammo > 0)
    else
      return super
    end
  end
  
=begin
    if target.hiding and target.unit_type == SUB
      return true if (DamageChart::PriDamage[@unit_type][target.unit_type] != -1 and @ammo > 0)
    end
    if DamageChart::PriDamage[@unit_type][target.unit_type] != -1 and @ammo > 0
      return true
    elsif DamageChart::SecDamage[@unit_type][target.unit_type] != -1
      return true
    else
      return false
    end
  end
=end  
end
$UNITS.push(Sub)