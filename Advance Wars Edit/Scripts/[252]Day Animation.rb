class Day_Animation
  
  DAY_ANIMATION_ID = 114
  
  def initialize
    @sprite = RPG::Sprite.new
    @sprite.x, @sprite.y = 320, 240
  end
  
  
  def animate
    day = $game_map.day.to_s.split(//)
    anim = $data_animations[DAY_ANIMATION_ID].clone
    
    num1 = day[0].to_i + 5
    num2 = day[1].nil? ? 15 : day[1].to_i + 5
    
    puts "day animation: #{num1} #{num2}"
    
    anim.frames.each{|frame|
      if frame.cell_data[5, 0] != -1
        frame.cell_data[5, 0] = num1
      end
      if frame.cell_data[6,0] != -1
        frame.cell_data[6,0] = num2
      end
    }
    @sprite.animation(anim, true)
  end
  
  
  def update
    @sprite.update
  end
  
  
  def dispose
    @sprite.dispose
  end
  
  
  def stop
    @sprite.animation(nil, true)
  end
  
end