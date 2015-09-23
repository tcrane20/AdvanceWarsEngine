class Factory < Property
  
  def initialize(x, y, army = 0)
    super(x, y, army)
    @name = 'factory'
    @id = TILE_FACTORY
    @ai_value = 1000
  end
  
  def build_list(army)
    x,y = -1,-1
    return [Infantry.new(x,y,army),Bike.new(x,y,army),Mech.new(x,y,army),Recon.new(x,y,army),Apc.new(x,y,army),Artillery.new(x,y,army),Tank.new(x,y,army),AntiAir.new(x,y,army),Missile.new(x,y,army),Antitank.new(x,y,army),Rocket.new(x,y,army),MdTank.new(x,y,army),Neotank.new(x,y,army), Megatank.new(x,y,army)]
  end
  #-------------------------------------------------------------------------
  #  Checks if the specified unit can be repaired on this property.
  # Heals land units.
  #-------------------------------------------------------------------------
  def can_repair(unit)
    return false if @army != unit.army
    return true if [MOVE_FOOT, MOVE_MECH, MOVE_TIRE, MOVE_TREAD, MOVE_TIRE_B].include?(unit.move_type)
    return false
  end
end
