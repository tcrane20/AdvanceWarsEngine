class City < Property
  
  def initialize(x, y, army = 0)
    super(x, y, army)
    @name = 'city'
    @id = TILE_CITY
    @ai_value = 200
  end
  
  def build_list
    return false unless @army.officer.build_on_cities
    return [Infantry, Bike, Mech, Recon, Apc, Artillery, Tank, AntiAir, Missile, Antitank, Rocket, MdTank, Neotank, Megatank]
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
