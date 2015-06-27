################################################################################
# Class Artillery
#   Cost : 6000                 Move : 5      Move Type : Tread
#   Vision : 1                  Fuel : 70
#   Primary Weapon : Cannon                   Ammo : 9
#   Secondary Weapon : None
################################################################################
class Artillery < Unit
  def initialize(x, y, army)
    super(x, y, army)
    @name = "artillery"
    @real_name = "Artillery"
    @unit_type = 4
    @cost = 6000
    @move = 5
    @move_type = 3
    @max_fuel = 70
    @fuel = 70
    @max_ammo = 9
    @ammo = 9
    @weapon1 = "Cannon"
    @weapon1_effect = [2, 2, 1, 1, 0, 0]
    @min_range = 2
    @max_range = 3
    @star_energy = 50
    @move_se = "tread"
    
    @stat_desc = ["Artillery are an inexpensive way to attack units from a distance.",
      "Artillery move on treads, making them easier to deploy than rockets.",
      "Artillery cannot attack in Fog of War without help from other units.",
      "The unit moves on fuel. It can no longer move if it drops to zero.",
      "Artillery attack with a cannon. It can attack ground units from afar.",
      "The attack deals great damage to infantry.",
      "The attack deals great damage to vehicles, even against stronger tanks.",
      "The attack is somewhat effective against boats.",
      "The attack is somewhat effective against surfaced subs.",
      "This unit can no longer attack when it runs out of ammo.", "", "","", ""]
  end
  
  def description
    return "An inexpensive indirect unit that can deal great damage."
  end
end
$UNITS.push(Artillery)