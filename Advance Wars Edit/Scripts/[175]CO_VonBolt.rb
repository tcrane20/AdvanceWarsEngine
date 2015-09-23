################################################################################
# Class VonBolt
#   Army: Black Hole           Power Bar: X X X X X X X X X X
#
# - 110/110 Units
# - His units cannot be affected by negative stat drops
#
# Super Power: Ex Machina
# - Damages units in a radius 2 square for 5 HP damage, which also causes the
#   units affected to not move the next turn (Von Bolt's units are unaffected)
# - 130/130 Units  
################################################################################
class CO_VonBolt < CO
  def initialize(army=nil)
    super(army)
    @name = "Von Bolt"
    @cop_name = "None"
    @scop_name = "Ex Machina"
    @description = [
    "Black Hole", "Eternal Life", "Young 'uns",
    "The mysterious leader of Black Hole. His chair contains enough power to keep him alive despite his age.",
    "All units have improved offense and defense capabilities.",
    "Von Bolt has no CO Power. He focuses all his energy for his Super CO Power.",
      "Emits a plasma wave that deals 5HP damage to all units in range. These units cannot move during their next turn. Von Bolt's troops are unaffected.",
    "Leader of the Bolt Guard. Units have increased stats. His power, which takes a while to charge, damages and paralyzes units in a small radius."]
    @cop_stars = 0
    @scop_stars = 10
  end
  
  def atk_bonus(unit)
    return 110
  end
  
  def def_bonus(unit)
    return 130 if @scop
    return 110
  end
  
  def use_scop
    super
    # Find best missile spot
    loc = $scene.find_best_missile_spot(2)
    # Get all the spots where this missile hits
    positions = $game_map.get_spaces_in_area(loc[0],loc[1],2)
    positions.each{|pos|
      # Get unit at this spot
      u = $game_map.get_unit(pos[0],pos[1])
      next if (u.nil? or u.army == @army)
      # Damage it and apply status effect
      u.injure(50, false, false)
      u.disabled = true
    }
    $game_player.moveto(loc[0],loc[1], true)
  end
  
  
end
$CO.push(CO_VonBolt)