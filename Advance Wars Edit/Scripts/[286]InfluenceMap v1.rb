class InfluenceMap
  attr_accessor :map
  def initialize
    @map = Array2D.new($game_map.width, $game_map.height)
    for y in 0...$game_map.height
      for x in 0...$game_map.width
        @map[x,y] = InfluenceData.new
      end
    end
    # Required to get move costs of tiles
    @dummy_army = Army.new(-1, -1)
    @dummy_unit = Unit.new(0,0,@dummy_army)
  end
  #-----------------------------------------------------------------------------
  def clear_map
    @map.flatten.each{|tile| tile.reset}
  end
  #-----------------------------------------------------------------------------
  def generate_map
    t=Time.now
    
    
    clear_map
    # For each tile on map
    for y in 0...$game_map.height
    for x in 0...$game_map.width
      unit = $game_map.get_unit(x,y)
      if !unit.nil?
        # Get attack range of this unit
        @locations = $scene.calc_pos(unit, "ai")
        # Calculate influence value and add it to the army's index
        infval = calc_unit_influence(unit)
        infval = Array.new(TOTAL_MOVETYPES, infval)
        # For each range this unit can occupy/attack
        @locations.flatten.compact.each{|loc|
          # Push unit into its army influence list
          @map[loc.x,loc.y].units_in_range[unit.army.id-1].push(unit)
          # Assign the influence at this current location
          @map[loc.x,loc.y].unit_infl[unit.army.id-1].best(infval)
        }
      end
      # Checking for property influence
      tile = $game_map.get_tile(x,y)
      if tile.is_a?(Property)
        if tile.army == 0
          @map[x,y].nprop_infl.all = tile.ai_value
        else
          @map[x,y].prop_infl[tile.army.id-1].all = tile.ai_value
        end
      end
    end
    end
    # Generate influence map values
    generate_inf_values
    puts Time.now - t
  end
  #-----------------------------------------------------------------------------
  def draw_infl(type)
    @sprites.each{|s| s.bitmap.dispose; s.dispose} unless @sprites.nil?
    @sprites = []
    highest_value = 0
    $maxy = 500 if $maxy.nil?
    for y in 0...$game_map.height
      for x in 0...$game_map.width
        player = @map[x,y].unit_infl[0][type] + @map[x,y].prop_infl[0][type]
        enemy  = @map[x,y].unit_infl[1][type] + @map[x,y].prop_infl[1][type]
        value = player - enemy
        @map[x,y].inf_value[0] = player
        @map[x,y].inf_value[1] = enemy
        s = Sprite.new
        s.bitmap = Bitmap.new(32,32)
        c = value > 0 ? Color.new(255,0,0,255*[value, $maxy].min / $maxy) : value < 0 ? Color.new(0,0,255,255*[value.abs, $maxy].min / $maxy) : Color.new(0,0,0)
        s.bitmap.fill_rect(0,0,32,32,c)
        s.z = 10000
        s.x = x * 32
        s.y = y * 32
        @sprites.push(s)
        highest_value = [highest_value, value.abs].max
      end
    end
    puts highest_value
    $maxy = highest_value
  end
  #-----------------------------------------------------------------------------
  def calc_unit_influence(unit)
    p = DamageChart::PriDamage[unit.unit_type].max if unit.ammo > 0
    s = DamageChart::SecDamage[unit.unit_type].max
    attack = [p, s, 0].compact.max
    cost = unit.cost / 1000.0
    range = unit.max_range == 1 ? unit.move + 1 : unit.max_range
    
    return (attack * (range + cost)).to_i / 5
  end
  #-----------------------------------------------------------------------------
  def generate_inf_values
    3.times{
    x, y = 0, 0
    while y < $game_map.height
      while x < $game_map.width
        $game_map.army.each_index{|i| #next if $game_map.army[i].nil?
          @map[x, y].unit_infl[i].best(find_uinf_value(x, y, -1, i))
          @map[x, y].prop_infl[i].best(find_pinf_value(x, y, -1, i))
        }
        @map[x, y].nprop_infl.best(find_npinf_value(x, y, -1))
        x+=1
      end
      x=0
      y+=1
    end
    
    x, y = $game_map.width-1, $game_map.height-1
    while y >= 0
      while x >= 0
        $game_map.army.each_index{|i| #next if $game_map.army[i].nil?
          @map[x, y].unit_infl[i].best(find_uinf_value(x, y, 1, i))
          @map[x, y].prop_infl[i].best(find_pinf_value(x, y, 1, i))
        }
        @map[x, y].nprop_infl.best(find_npinf_value(x, y, 1))
        x-=1
      end
      x=$game_map.width-1
      y-=1
    end
    }
  end
  #-----------------------------------------------------------------------------
  def find_uinf_value(x, y, dir, army_id)
    
    best_set = []
    
    TOTAL_MOVETYPES.times{|i|
      a, b = 0, 0
      @dummy_unit.move_type = i
      if (x+dir).between?(0,$game_map.width-1)
        if $game_map.get_tile(x+dir,y).move_cost(@dummy_unit) != 0
          a = @map[x + dir, y].unit_infl[army_id][i]
        end
      end
      
      if (y+dir).between?(0,$game_map.height-1)
        if $game_map.get_tile(x,y+dir).move_cost(@dummy_unit) != 0
          b = @map[x, y + dir].unit_infl[army_id][i]
        end
      end
      
      best_set[i] = [[a,b].max - 25, 0].max
    }
    
    return best_set
  end
  #-----------------------------------------------------------------------------
  def find_pinf_value(x, y, dir, army_id)
    
    best_set = []
    
    TOTAL_MOVETYPES.times{|i|
      a, b = 0, 0
      @dummy_unit.move_type = i
      if (x+dir).between?(0,$game_map.width-1)
        if $game_map.get_tile(x+dir,y).move_cost(@dummy_unit) != 0
          a = @map[x + dir, y].prop_infl[army_id][i]
        end
        
      end
      
      if (y+dir).between?(0,$game_map.height-1)
        if $game_map.get_tile(x,y+dir).move_cost(@dummy_unit) != 0
          b = @map[x, y + dir].prop_infl[army_id][i]
        end
        
      end
      
      best_set[i] = [[a,b].max - 25, 0].max
    }
    
    return best_set
  end
  #-----------------------------------------------------------------------------
  def find_npinf_value(x, y, dir)
    best_set = []
    
    TOTAL_MOVETYPES.times{|i|
      a, b = 0, 0
      @dummy_unit.move_type = i
      if (x+dir).between?(0,$game_map.width-1)
        if $game_map.get_tile(x+dir,y).move_cost(@dummy_unit) != 0
          a = @map[x + dir, y].nprop_infl[i]
        end
      end
      
      if (y+dir).between?(0,$game_map.height-1)
        if $game_map.get_tile(x,y+dir).move_cost(@dummy_unit) != 0
          b = @map[x, y + dir].nprop_infl[i]
        end
        
      end
      
      best_set[i] = [[a,b].max - 25, 0].max
    }
    
    return best_set
  end
  #-----------------------------------------------------------------------------
  
  def set_best_move(move)
    @found_move = true if move[4] != "move"
    if @best_move[0] < move[0]
      @best_move = move
    end
  end
  #-----------------------------------------------------------------------------
  def determine_best_move(army_id)
    t = Time.now
    @best_move = [-99999, nil]
    $game_map.army[army_id].units.each{|unit|
      next if unit.acted
      # If capturing a property, finish the capture
      if unit.capturing
        set_best_move([9999, unit, unit.x, unit.y, "capt"])
        next
      end
      @found_move = false
      # Get positions most significant to unit (attack range)
      positions = $scene.calc_pos(unit, unit.max_range == 1 ? "move" : "attack")
      positions.flatten.compact.each{|pos|
        tile = $game_map.get_tile(pos.x,pos.y)
        other_unit = $game_map.get_unit(pos.x,pos.y)
        # If this unit can capture properties
        if unit.can_capture && other_unit.nil?
          inf_value = @map[pos.x,pos.y].prop_infl[1] + @map[pos.x,pos.y].nprop_infl
          if tile.is_a?(Property) && tile.army != unit.army # Capture this property
            set_best_move([inf_value + tile.ai_value, unit, pos.x, pos.y, "capt"])
          else # Move towards a property
            set_best_move([inf_value, unit, pos.x, pos.y, "move"])
          end
        end
        # CHeck for attacking
        
        if unit.ammo > 0 || unit.secondary
          # Direct combat
          if unit.max_range == 1 && other_unit.nil?
            direct = $scene.calc_pos(unit, "direct")
            direct.each{|target|
              enemy = $game_map.get_unit(target[0], target[1])
              if !enemy.nil? && enemy.army != unit.army
                damages = unit.fire(DMG_AI, enemy)
                set_best_move([damages[0]-damages[1], unit, pos.x, pos.y, "fire", target[0], target[1]])
              end
            }
          elsif unit.max_range > 1
            if !other_unit.nil? && other_unit.army != unit.army
              damages = unit.fire(DMG_AI, other_unit)
              set_best_move([damages[0]-damages[1], unit, pos.x, pos.y, "fire", pos.x, pos.y])
            end
          end
        end
        
        # Check for best default move, if attack wasn't made
        unless @found_move
          if unit.max_range > 1
            $scene.calc_pos(unit, "move").flatten.compact.each{|spot|
              next if !$game_map.get_unit(spot.x, spot.y).nil?
              a = @map[spot.x,spot.y].inf_value[0] + @map[spot.x,spot.y].prop_infl[0]
              b = @map[spot.x,spot.y].inf_value[1] + @map[spot.x,spot.y].prop_infl[1]
              set_best_move([b-a, unit, spot.x, spot.y, "move"])
            }
          elsif other_unit.nil?
            a = @map[pos.x,pos.y].inf_value[0] + @map[pos.x,pos.y].prop_infl[0]
            b = @map[pos.x,pos.y].inf_value[1] + @map[pos.x,pos.y].prop_infl[1]
            set_best_move([b-a, unit, pos.x, pos.y, "move"])
          end
          
        end
        
      } # End positions.each 
    } # End units.each
    puts Time.now - t
    u = @best_move.delete_at(1)
    p [u.class, u.x, u.y] unless u.nil?
    p @best_move
  end
  
end






#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
class InfluenceData
  attr_accessor :unit_infl, :prop_infl, :inf_value, :nprop_infl, :units_in_range
  
  def initialize
    @unit_infl = Array.new(4){|i| MoveType_Influence.new}
    @prop_infl = Array.new(4){|i| MoveType_Influence.new}
    @nprop_infl = MoveType_Influence.new
    
    @units_in_range = [[],[],[],[]]
    @inf_value = [0,0,0,0]
  end
  
  def reset
    @unit_infl.each{|a| a.clear}
    @prop_infl.each{|a| a.clear}
    @nprop_infl.clear
    
    @units_in_range = [[],[],[],[]]
    @inf_value = [0,0,0,0]
  end
  

end
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
class MoveType_Influence
  
  def initialize
    @data = Array.new(TOTAL_MOVETYPES, 0)
  end
  
  def [](id)
    @data[id]
  end
  
  def []=(id, val)
    @data[id] = val
  end
  
  def max
    @data.max
  end
  
  def best(array)
    @data.each_index{|i| @data[i] = [@data[i], array[i]].max }
  end
  
  
  def all=(val)
    @data.each_index{|i| @data[i] = val}
  end
  
  def clear
    @data.each_index{|i| @data[i] = 0}
  end
  
end


