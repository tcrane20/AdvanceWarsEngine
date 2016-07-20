class ComTower < Property
  
  def initialize(x, y, army = 0)
    super(x, y, army)
    @name = 'comtower'
    @id = TILE_COMTOWER
    @ai_value = 1250
  end
  
end
