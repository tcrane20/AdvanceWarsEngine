################################################################################
# Class Antitank
#   Cost : 13000                Move : 4      Move Type : Tire B
#   Vision : 1                  Fuel : 40
#   Primary Weapon : Cannon                   Ammo : 5
#   Secondary Weapon : None
################################################################################
class Antitank < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "antitank"
    @real_name = "Anti-Tank"
    @unit_type = 25
    @cost = 13000
    @move = 4
    @move_type = MOVE_TIRE_B
    @max_fuel = 40
    @fuel = 40
    @max_ammo = 5
    @ammo = 5
    @weapon1 = "Cannon"
    @weapon1_effect = [2, 2, 1, 1, 0, 0]
    @min_range = 1
    @max_range = 3
    @star_energy = 100
    @move_se = "tread"
    
    @stat_desc = ["Anti-tanks are capable of counter attacking, dealing high damage.",
      "Anti-tanks move slowly, but travel on more efficient wheels.",
      "Anti-tanks cannot utilize their range in Fog of War without help.",
      "The unit moves on fuel. It can no longer move if it drops to zero.",
      "Anti-tanks fire cannons that can attack distant or close targets.",
      "The attack deals great damage to infantry.",
      "Anti-tanks can fare well against most vehicles, even against Megatanks.",
      "The attack is poor against ships.",
      "The attack is poor against surfaced subs.",
      "This unit can no longer attack when it runs out of ammo.", "", "","", ""]
  end
  
  def description
    return "A defensive indirect unit that can counter attack."
  end
end
$UNITS.push(Antitank)