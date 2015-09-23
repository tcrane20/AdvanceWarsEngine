=begin
_________________
 MoveTile        \______________________________________________________________
 
 Information class. For each tile drawn in a range, this object exists. Holds
 (x,y), cost to move onto here, and total movement cost to reach here. Needed
 in particular for Scene_Map#calc_pos.
 
 Notes:
 * Does this apply only to move ranges, or to any and all ranges? If so, name
 class differently.
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class MoveTile
  attr_accessor :x, :y, :cost, :total_cost
  
  def initialize(x, y, cost=nil, total_cost=nil)
    @x = x
    @y = y
    @cost = cost
    @total_cost = total_cost
  end
  
  
  # Because I'm too lazy to change my code
  def [](x_y)
    return @x if x_y == 0
    return @y if x_y == 1
  end
  
  
  
  # Check if attack tile
  def attack?
    return @cost.nil? || @total_cost.nil?
  end
  
end
