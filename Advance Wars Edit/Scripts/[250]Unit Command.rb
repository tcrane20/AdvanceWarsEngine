
# Scene_Map variable to hold information about what to command the unit to do
  
class Unit_Command
  attr_accessor :move, :action, :target
  
  def initialize
    @move = nil
    @action = nil
    @target = []
  end
  
  def action=(action)
    # Only assigns an action if currently nil or setting it to nil
    @action = action if @action.nil? || action.nil?
  end
      
  def action_drop(x, y, unit)
    @target.push([x,y,unit])
  end
  
  def drop_loc(index)
    return nil if index >= @target.size
    return [@target[index][0], @target[index][1]]
  end
  
  def drop_unit(index)
    return nil if @target.size < index
    return @target[index][2]
  end
  
end
