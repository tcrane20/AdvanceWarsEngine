class Airport < Property
  
  def initialize(x, y, army = 0)
    super(x, y, army)
    @name = 'airport'
    @id = TILE_AIRPORT
    @ai_value = 500
  end
  
  def build_list(army)
    x,y = -1,-1
    return [Tcop.new(x,y,army),Bcop.new(x,y,army),Zeppelin.new(x,y,army),Fighter.new(x,y,army),Bomber.new(x,y,army),Stealth.new(x,y,army)]
  end
  #-------------------------------------------------------------------------
  #  Checks if the specified unit can be repaired on this property.
  # Heals air units.
  #-------------------------------------------------------------------------
  def can_repair(unit)
    return false if @army != unit.army
    return true if [MOVE_AIR].include?(unit.move_type)
    return false
  end
end
