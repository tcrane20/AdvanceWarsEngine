################################################################################
# Class Cruiser
#   Cost : 15000                Move : 6      Move Type : Water
#   Vision : 4                  Fuel : 99
#   Primary Weapon : Rockets                  Ammo : 6
#   Secondary Weapon : Machine Gun
################################################################################
class Cruiser < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "cruiser"
		@real_name = "Cruiser"
    @unit_type = 16
    @cost = 15000
    @move = 6
    @move_type = 6
    @vision = 4
    @fuel_cost = 1
    @max_ammo = 9
    @ammo = 9
		@weapon1 = "Anti-Sub Missiles"
		@weapon2 = "Anti-Air Gun"
		@weapon1_effect = [0, 0, 1, 2, 0, 0]
		@weapon2_effect = [0, 0, 0, 0, 2, 2]
    @star_energy = 125
    @can_carry = true
		@move_se = "ship"
		
		@stat_desc = ["Cruisers control the air and sea with an assortment of weaponry. They can also carry two copter units.",
			"Cruisers move a far distance. They travel through the sea.",
			"This unit can see quite far in Fog of War.",
			"The unit burns 1 unit of fuel each day. It sinks when it drops to zero.",
			"Cruisers are armed with anti-sub missiles to attack sea units.",
			"Don't expect much damage against most ships.",
			"Cruisers can engage hidden subs and do massive damage.", "", "",
			"Cruisers have a potent anti-air gun.",
			"The attack can wipe out whole copters in one shot.",
			"The attack is fairly effective against planes.", "", ""]
  end
  
  def description
    return "A ship that rids the seas from subs and air units."
  end
	
	def carry_capability(unit)
    return false if @holding_units.size == 2
    return true if [TCP, BCP].include?(unit.unit_type)
    return false
  end
	
	def carry_effect
		bool = false
		@holding_units.each{|u| 
			next unless (u.fuel < u.max_fuel or u.ammo < u.max_ammo)
			u.supply
			bool = true
		}
		return bool
	end
	
  #-----------------------------------------------------------------------------
  # Checks if the unit is over a tile that it can drop units off.
  #-----------------------------------------------------------------------------
  def valid_drop_spot(x,y)
    return true
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
$UNITS.push(Cruiser)