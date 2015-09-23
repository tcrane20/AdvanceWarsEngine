class Day_Graphic < Sprite
  
  def initialize(viewport = nil)
    super(viewport)
    @bltmap = RPG::Cache.picture('day_graphic')
    @cur_day = $game_map.day
    @width = 64
    self.bitmap = Bitmap.new(64, 30)
    # Draw the "Day" graphic
    self.bitmap.blt(0, 0, @bltmap, Rect.new(0,0,34,30))
  end
  
  def update
    return if @cur_day != $game_map.day
    @cur_day = $game_map.day
    x = 40
    # Evaluate each digit
    @cur_day.to_s.split(//).each{|digit|
      left_shift, rect = get_draw_coords(digit.to_i)
      self.bitmap.blt(x, 0, @bltmap, rect)
      x += 10 - left_shift
    }
    @width = x + 2
  end
  
  def get_draw_coords(num)
    if num == 1
      return [4, Rect.new(14,30,8,24)]
    else
      return [0, Rect.new(12 * num, 30, 12, 24)]
    end
  end
  
  def width
    return @width
  end
  
end
