################################################################################
# Class Fighter
#   Cost : 18000                Move : 9      Move Type : Air
#   Vision : 2                  Fuel : 80
#   Primary Weapon : Missile                  Ammo : 9
#   Secondary Weapon : None
################################################################################
class Fighter < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "fighter"
		@real_name = "Fighter"
    @unit_type = 13
    @cost = 18000
    @move = 9
    @move_type = 4
    @vision = 2
    @max_fuel = 80
    @fuel = 80
    @fuel_cost = 5
    @max_ammo = 9
    @ammo = 9
		@weapon1 = "Missiles"
		@weapon1_effect = [0, 0, 0, 0, 2, 2]
    @star_energy = 175
    @move_se = "plane"
		
		@stat_desc = ["Fighters are quick jets that can deal great damage to air units.",
			"Fighters have the highest movement. It is unaffected by terrain.",
			"The vision of this unit is somewhat weak.",
			"The unit burns 5 units of fuel each day. It crashes when it drops to zero.",
			"Fighters attack with air missiles. It can only engage air units.",
			"Fighters can wipe out copters in one shot.",
			"Fighters deal very high damage to planes, especially bombers.", "", "",
			"Fighters can no longer attack when they run out of ammo.", "", "","", ""]
  end
  
  def description
    return "A swift air unit that destroys enemy aircraft."
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
  
=begin
    if target.hiding and target.unit_type == STH
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
$UNITS.push(Fighter)