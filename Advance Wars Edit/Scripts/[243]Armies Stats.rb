class SecondScreen
  
  def initialize
    @viewport = Viewport.new(0,0,640,480)
    @viewport.z = 99999
    @officer_tags = []
    i = 1
    $game_map.army.each{|army| next if army.nil?
      ot = Officer_Tag_Graphic.new(@viewport, army, false)
      ot.y = 60 * i + 40
      p ot.y
      @officer_tags.push(ot)
      i += 1
    }
  end
  
  def update
    @officer_tags.each{|ot| ot.update}
  end
  
end
