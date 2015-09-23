class HQ < City
  
  def initialize(x, y, army = 0)
    super(x, y, army)
    @name = 'hq'
    @id = TILE_HQ
    @defense = 4
    @ai_value = 2000
  end
  #-------------------------------------------------------------------------
  #  Sets the property's army type. Also modifies the graphic on the map.
  # If arg "army" = 0, then the method will treat the property as unowned.
  # Needed to be extended to add "player has lost" command.
  #-------------------------------------------------------------------------
  def army=(army)
    # Get the tile ID
    tile = $game_map.data[@x, @y, 0]
    # If army lost, then turn HQ into city
    result = false
    if army.is_a?(Army)
      if (@army.is_a?(Integer) and @army != army.id) or @army != army
        result = true
      end
    else
      if (@army.is_a?(Integer) and @army != army) or @army != army.id
        result = true
      end
    end
    result = false if @id == TILE_CITY
    if result
      @army.lost_battle = 2
      @name = 'city'
      @id = TILE_CITY
      @defense = 3
      tile -= 31
    end
    # Find which army owned this property before (0 = unowned)
    prev_army = 0
    if !@army.is_a?(Integer)
      prev_army = @army.id
      # Remove this property from army
      @army.owned_props.delete(self)
    else
      prev_army = @army
    end
    tile -= prev_army
    # Set the army value.
    @army = army
    # Change the tile to the correct army possession
    if !@army.is_a?(Integer)
      $game_map.data[@x, @y, 0] = tile + @army.id
      return if @y-1 < 0
      $game_map.data[@x, @y-1, 1] = tile + @army.id - 8
    else
      $game_map.data[@x, @y, 0] = tile
      return if @y-1 < 0
      $game_map.data[@x, @y-1, 1] = tile - 8
    end
  end

  
  def build_list(army)
    return false if @id == TILE_HQ
    return false unless army.officer.build_on_cities
    x,y = -1,-1
    return [Infantry.new(x,y,army),Bike.new(x,y,army),Mech.new(x,y,army),Recon.new(x,y,army),Apc.new(x,y,army),Artillery.new(x,y,army),Tank.new(x,y,army),AntiAir.new(x,y,army),Missile.new(x,y,army),Antitank.new(x,y,army),Rocket.new(x,y,army),MdTank.new(x,y,army),Neotank.new(x,y,army),Megatank.new(x,y,army)]
  end

end
