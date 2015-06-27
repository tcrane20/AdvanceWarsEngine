class Seaport < Property
  
  def initialize(x, y, army = 0)
    super(x, y, army)
    @name = 'seaport'
    @id = TILE_SEAPORT
    @ai_value = 500
  end
  
  def move_cost(unit)
    if ($game_map.current_weather == 'snow' and !unit.army.officer.no_snow_penalty) or
      ($game_map.current_weather == 'rain' and unit.army.officer.name == 'Olaf')
      case unit.move_type
      when MOVE_FOOT then return 1
      when MOVE_MECH then return 1
      when MOVE_TIRE then return 1
      when MOVE_TREAD then return 1
      when MOVE_AIR then return 2
      when MOVE_TRANS then return 1
      when MOVE_SEA then return 1
      when MOVE_TIRE_B then return 1
      end
    else
      case unit.move_type
      when MOVE_FOOT then return 1
      when MOVE_MECH then return 1
      when MOVE_TIRE then return 1
      when MOVE_TREAD then return 1
      when MOVE_AIR then return 1
      when MOVE_TRANS then return 1
      when MOVE_SEA then return 1
      when MOVE_TIRE_B then return 1
      end
    end
  end
  
  def build_list(army)
    x,y = -1,-1
    return [Lander.new(x,y,army),Cruiser.new(x,y,army),Destroyer.new(x,y,army),Sub.new(x,y,army),Bship.new(x,y,army),Carrier.new(x,y,army)]
  end
  #-------------------------------------------------------------------------
  #  Checks if the specified unit can be repaired on this property.
  # Heals sea units.
  #-------------------------------------------------------------------------
  def can_repair(unit)
    return false if @army != unit.army
    return true if [MOVE_TRANS, MOVE_SEA].include?(unit.move_type)
    return false
  end
end
