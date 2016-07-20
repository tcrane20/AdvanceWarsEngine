################################################################################
# Class Bcop
#   Cost : 9000                 Move : 6      Move Type : Air
#   Vision : 3                  Fuel : 99
#   Primary Weapon : Missile                  Ammo : 6
#   Secondary Weapon : Machine Gun
################################################################################
class Bcop < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "bcopter"
    @real_name = "B. Copter"
    @unit_type = 12
    @cost = 9000
    @move = 6
    @move_type = 4
    @vision = 3
    @fuel_cost = 3
    @max_ammo = 6
    @ammo = 6
    @weapon1 = "Missiles"
    @weapon2 = "Machine Gun"
    @weapon1_effect = [0, 2, 1, 1, 0, 0]
    @weapon2_effect = [2, 1, 0, 0, 2, 0]
    @star_energy = 85
    @move_se = "copter"
    
    @stat_desc = ["Battle copters are an inexpensive way to engage multiple units.",
      "This unit moves a far distance. It is unaffected by terrain.",
      "Battle copters have a decent vision range.",
      "The unit burns 3 units of fuel each day. It crashes when it drops to zero.",
      "These copters attack with air-to-surface missiles.",
      "This unit does solid damage to most ground units.",
      "The attack does some damage to ships.",
      "The attack does some damage to surfaced subs.", "",
      "Battle copters are also equipped with a powerful machine gun.",
      "Battle copters do slightly more damage to infantry than tanks.",
      "The attack is somewhat effective against indirect-attacking vehicles.",
      "Battle copters can do massive damage to other copter units.", ""]
  end
  
  def description
    return "An inexpensive air unit capable of combatting a variety of units."
  end
end
$UNITS.push(Bcop)