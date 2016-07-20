class Property < Tile
  #-------------------------------------------------------------------------
  #  Mother of properties.
  # When initialized, @army value is a variable. During scene, it will then
  # have its @army value set to the actual Army class.
  #-------------------------------------------------------------------------
  attr_accessor :id, :capt, :army, :x, :y, :ai_value
  def initialize(x=0, y=0, army = 0)
    @name = ''
    @id = -1
    @x = x
    @y = y
    @defense = 3
    @capt = 20
    @army = army
    @vision = 1
    
    @ai_value = 0
  end
  #-------------------------------------------------------------------------
  #  Defines what can be built on this property. Defined in sub-classes.
  #-------------------------------------------------------------------------
  def build_list
    return false
  end
  #-------------------------------------------------------------------------
  #  Sets the property's army type. Also modifies the graphic on the map.
  # If arg "army" = 0, then the method will treat the property as unowned.
  #-------------------------------------------------------------------------
  def army=(army)
    # Get the tile ID
    tile = $game_map.data[@x, @y, 0]
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
    # Set the army value
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
  
end

