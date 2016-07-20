################################################################################
# Class Mech
#   Cost : 3000                 Move : 2      Move Type : Foot B
#   Vision : 2                  Fuel : 70
#   Primary Weapon : Bazooka                  Ammo : 3
#   Secondary Weapon : Machine Gun
################################################################################
class Mech < Unit
  def initialize(*args)
    super(*args)
    @name = "mech"
    @nation_gfx = true # Changes the sprite based on CO's nation
    @real_name = "Mech"
    @unit_type = 1
    @cost = 3000
    @move = 2
    @move_type = 1
    @vision = 2
    @max_fuel = 70
    @fuel = 70
    @max_ammo = 3
    @ammo = 3
    @weapon1 = "Bazooka"
    @weapon2 = "Machine Gun"
    @weapon1_effect = [0, 2, 0, 0, 0, 0]
    @weapon2_effect = [2, 1, 0, 0, 1, 0]
    @star_energy = 35
    @move_se = "foot"
    @can_capture = true
    
    @stat_desc = ["A stronger version of the infantry unit that can capture properties.",
      "Mechanized infantry travel on foot. Their gear bogs them down, but they can travel most terrain without trouble.",
      "When standing on a mountain, Mechs can see an additional 3 spaces.",
      "Mechs travel using rations. When these rations are gone, they can no longer move.",
      "Mechanized infantry carry bazookas. They can attack small vehicles but possess low ammo.",
      "Mechs do as much damage as a tank\'s cannon. It deals good damage to most vehicles.",
      "", "", "",
      "The secondary weapon is a machine gun. It is slightly stronger than an infantry\'s.",
      "Mechs deal more damage to infantry units with their machine gun.",
      "Don't expect machine guns to do much damage to vehicles.",
      "Mechs can do some damage to transport copters.",
      ""]
  end
  
  def description
    return "A stronger infantry unit capable of damaging small vehicles."
  end
end
$UNITS.push(Mech)