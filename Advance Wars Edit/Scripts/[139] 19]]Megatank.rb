################################################################################
# Class NeoTank
#   Cost : 20000                Move : 6      Move Type : Tread
#   Vision : 1                  Fuel : 50
#   Primary Weapon : Neo Cannon               Ammo : 6
#   Secondary Weapon : Machine Gun
################################################################################
class Megatank < Unit
  def initialize(*args)
    super(*args)
    @name = "megatank"
    @real_name = "Megatank"
    @unit_type = MEG
    @cost = 26000
    @move = 4
    @move_type = MOVE_TREAD
    @max_fuel = 50
    @fuel = 50
    @max_ammo = 3
    @ammo = 3
    @weapon1 = "Megacannon"
    @weapon2 = "Machine Gun"
    @weapon1_effect = [0, 2, 1, 1, 0, 0]
    @weapon2_effect = [2, 1, 0, 0, 1, 0]
    @star_energy = 200
    @move_se = "h_tread"
    
    @stat_desc = ["Invented by Green Earth, Megatanks are the strongest land unit.",
      "Megatanks move slower than most units. The unit travels on treads.",
      "The vision range of this unit is pitiful.",
      "The unit moves on fuel. It can no longer move if it drops to zero.",
      "Megatanks use, of course, the megacannon. It uses up ammo quickly.",
      "Megatanks can wipe out most vehicles in one shot, including Medium Tanks.",
      "The attack does decent damage to ships.",
      "The attack does decent damage to surfaced subs.", "",
      "Megatanks are armed with machine guns when their primary weapon runs out of ammo.",
      "Megatanks can wipe out infantry units in one shot.",
      "The attack is effective against indirect-attacking vehicles.",
      "The attack is effective against battle copters.", ""]
  end
  
  def description
    return "A huge tank that was designed by Green Earth."
  end
end
$UNITS.push(Megatank)