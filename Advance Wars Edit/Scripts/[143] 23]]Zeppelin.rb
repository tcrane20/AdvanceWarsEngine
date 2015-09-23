################################################################################
# Class Zeppelin
#   Cost : 10000                Move : 4      Move Type : Air
#   Vision : 2                  Fuel : 99
#   Primary Weapon : Omni-missiles            Ammo : 9
#   Secondary Weapon : None
################################################################################
class Zeppelin < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "zeppelin"
    @real_name = "Zeppelin"
    @unit_type = 23
    @cost = 10000
    @move = 4
    @move_type = MOVE_AIR
    @vision = 2
    @max_fuel = 99
    @fuel = 99
    @fuel_cost = 5
    @max_ammo = 9
    @ammo = 9
    @weapon1 = "Omni-missiles"
    @weapon2 = ""
    @weapon1_effect = [2, 2, 1, 1, 2, 1]
    @min_range = 3
    @max_range = 4
    @star_energy = 90
    @move_se = "copter"
    
    @stat_desc = ["Zeppelins are indirect air units that can target any type of unit.",
      "Zeppelins move quite slowly. They are unaffected by terrain.",
      "This unit must rely on others in order to launch attacks.",
      "The unit burns 3 units of fuel each day. It crashes when it drops to zero.",
      "Zeppelins use ranged omni-missiles to attack any unit.",
      "Zeppelins do good damage to infantry.",
      "This unit does good damage against smaller vehicles.",
      "This unit does not do much damage against ships.",
      "The unit does not do much damage against surfaced subs.", "",
      "The attack is very effective against copters.",
      "The attack does somewhat moderate damage to planes.", "", ""]
  end
  
  def description
    return "An inexpensive indirect unit that can attack all units."
  end
end
$UNITS.push(Zeppelin)