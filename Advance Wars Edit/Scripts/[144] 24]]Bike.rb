################################################################################
# Class Infantry
#   Cost : 1000                 Move : 3      Move Type : Foot A
#   Vision : 2                  Fuel : 99
#   Primary Weapon : None                     Ammo : N/A
#   Secondary Weapon : Machine Gun
################################################################################
class Bike < Unit
  def initialize(*args)
    super(*args)
    @name = "bike"
    @real_name = "Bike Infantry"
    @unit_type = BIK
    @cost = 2500
    @move = 5
    @move_type = MOVE_TIRE_B
    @vision = 2
    @max_fuel = 70
    @fuel = 70
    @weapon2 = "Machine Gun"
    @weapon2_effect = [2, 1, 0, 0, 1, 0]
    @star_energy = 30
    @move_se = "wheels"
    @can_capture = true
    
    @stat_desc = ["These infantry units rely on speed moreso than power.",
      "Bike infantry move quickly. They ride on multi-terrain wheels.",
      "Because they cannot stand on mountains, they always have poor vision.",
      "Bikes use fuel. When fuel reaches zero, they can no longer move.",
      "Bike infantry units have no primary weapon.",
      "", "", "", "",
      "Bike infantry use a machine gun. It\'s not very powerful.",
      "Of the infantry types, bikes do the least damage to other infantry. It\'s still effective, however.",
      "Don\'t expect to do much damage to vehicles.",
      "Bike infantry can do some damage to transport copters.",
      ""]
  end
  
  def description
    return "A mobile, yet weaker, infantry unit that can capture buildings."
  end
  
end
$UNITS.push(Bike)