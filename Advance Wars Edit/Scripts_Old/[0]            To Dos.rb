=begin

Things I noticed:
  -Cursor is not invisible at appropriate times
  -CO Profiles scene not done (will error)
  -Flag sprites have high z-values; they overlap sprites that should be higher
  -Crashing units require a slight delay between them; right now, if more than one unit crashes,
   all will play their crash animation at the same time. Cursor needs to move to the first crashing unit,
   play animation, wait for animation to finish, then proceed to the next crashing unit.
  -Mouse click needs button assignment to it at appropriate times. Can't scroll
  down a window without triggering to select the item if left click = C.
  - Calculating unit stats based on unit's location is bugged (no decision_x/y does not exist)
  

Things I know I have finished
    * Improved CO bars (they flash and bounce--pretty!)
    * Sliding CO tag and info window; watch them accelerate on and off screen
    * Cleaned up a few existing things that really needed it
    * New methods regarding drawing ranges and calculating them (faster)
    * Bug fixes
      - Crashing units (fuel = 0) no longer cause weird errors
      - Units with specialized can_attack methods are fixed and make more sense
    * 3 player maps work. Haven't tried 4 players yet.
    * Tied with above, maps now have a configuration thingie at the top corner
    * Tilemap rewrite script works with this project
    * Started working on CO Power animations
    * Almost done ripping tileset sprites
    
    
    
    
=end    

  

class Node
  attr_accessor :value
  attr_accessor :next_node

  def initialize(v, n = nil)
    @value = v
    @next_node = n
  end
end

linked_list = Node.new(1)

linked_list.next_node = Node.new(2)

linked_list.next_node.next_node = Node.new(3)