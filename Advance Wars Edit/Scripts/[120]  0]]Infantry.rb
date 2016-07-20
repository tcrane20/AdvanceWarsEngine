################################################################################
# Class Infantry
#   Cost : 1000                 Move : 3      Move Type : Foot A
#   Vision : 2                  Fuel : 99
#   Primary Weapon : None                     Ammo : N/A
#   Secondary Weapon : Machine Gun
################################################################################
class Infantry < Unit
  def initialize(*args)
    super(*args)
    @name = "infantry"
    @nation_gfx = true # Changes the sprite based on CO's nation
    @real_name = "Infantry"
    @unit_type = INF
    @cost = 1000
    @move = 3
    @vision = 2
    @star_energy = 30
    @move_se = "foot"
    @weapon2 = "Machine Gun"
    @weapon2_effect = [2, 1, 0, 0, 1, 0]
    @can_capture = true
    
    @stat_desc = ["An inexpensive unit that has low firepower, good mobility, and the ability to capture properties.",
      "Infantry travel on foot. They can traverse almost any terrain without much trouble.",
      "When standing on a mountain, Infantry can see an additional 3 spaces.",
      "Infantry travel using rations. When these rations are gone, they can no longer move.",
      "Infantry units have no primary weapon.",
      "", "", "", "",
      "Infantry units secondary weapon is a machine gun. It\'s not very powerful.",
      "Infantry do great damage to other infantry units.",
      "Don\'t expect infantry units to do much damage to vehicles.",
      "Infantry can do some damage to transport copters.",
      ""]
  end
  
  def description
    return "An inexpensive unit that can capture properties."
  end
  
  
end
$UNITS.push(Infantry)