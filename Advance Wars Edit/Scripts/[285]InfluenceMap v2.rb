class InfluenceMap
  attr_accessor :map
  
  def initialize
    @map = Array2D.new($game_map.width, $game_map.height)
    for y in 0...$game_map.height
      for x in 0...$game_map.width
        @map[x,y] = InfluenceData.new
      end
    end
    # Distinguish regions based on what lies between these tiles
    @borders = [[TILE_SEA, TILE_REEF], [TILE_PIPE]]
    # Record instances of these inside region
    @vital_landmarks = [TILE_SHOAL, TILE_SEAPORT, TILE_JOINT]
    #
    @regions = {}
    define_regions
  end
  #-----------------------------------------------------------------------------
  def define_regions
    t = Time.now
    region_id = 1
    x, y = 0, 0
    
    while y < $game_map.height
      while x < $game_map.width
        # This tile hasn't been assigned a region
        if @map[x,y].regionid == 0
          tid = $game_map.get_tile(x,y).id
          # Find the border set this tile belongs to, or nil if not a border
          border_set = @borders.find{|set| set.include?(tid)}
          # Create a new region
          @map[x,y].regionid = region_id
          @regions[region_id] = Region.new(region_id)
          # Populate neighboring tiles with same region
          radiate_region(x,y,region_id,border_set)
          region_id += 1
        end
        x+=1
      end
      x=0
      y+=1
    end
    
    puts Time.now - t
    
    #@regions.values.each{|reg| p reg.id, reg.borders, reg.bridges}
  end
  #-----------------------------------------------------------------------------
  def radiate_region(x,y,id,border=nil)
    open_set = [[x,y]]
    while !open_set.empty?
      x, y = open_set.shift
      # Check left
      if x-1 >= 0
        rid = @map[x-1,y].regionid
        # This tile is not part of a region yet
        if rid == 0
          # Get neighboring tile's ID
          tid = $game_map.get_tile(x-1,y).id
          # If defining a border, check if tile is part of the border set.
          # Otherwise, check that the tile is not part of any border set.
          if !border.nil? ? border.include?(tid) : @borders.find{|set| set.include?(tid)} == nil
            # Populate this tile as part of the same region
            @map[x-1,y].regionid = id
            # Evaluate its neighbors next time
            open_set.push([x-1,y])
          end
        # Tile is assigned to a different region than the one currently being made
        elsif rid != id
          check_for_bridge_tiles($game_map.get_tile(x,y).id, $game_map.get_tile(x-1,y).id, id, rid)
          @regions[rid].add_border(id)
          @regions[id].add_border(rid)
        end
      end
      # Check right
      if x+1 < $game_map.width
        rid = @map[x+1,y].regionid
        # This tile is not part of a region yet
        if rid == 0
          # Get neighboring tile's ID
          tid = $game_map.get_tile(x+1,y).id
          # If defining a border, check if tile is part of the border set.
          # Otherwise, check that the tile is not part of any border set.
          if !border.nil? ? border.include?(tid) : @borders.find{|set| set.include?(tid)} == nil
            # Populate this tile as part of the same region
            @map[x+1,y].regionid = id
            # Evaluate its neighbors next time
            open_set.push([x+1,y])
          end
        # Tile is assigned to a different region than the one currently being made
        elsif rid != id
          check_for_bridge_tiles($game_map.get_tile(x,y).id, $game_map.get_tile(x+1,y).id, id, rid)
          @regions[rid].add_border(id)
          @regions[id].add_border(rid)
        end
      end
      # Check up
      if y-1 >= 0
        rid = @map[x,y-1].regionid
        # This tile is not part of a region yet
        if rid == 0
          # Get neighboring tile's ID
          tid = $game_map.get_tile(x,y-1).id
          # If defining a border, check if tile is part of the border set.
          # Otherwise, check that the tile is not part of any border set.
          if !border.nil? ? border.include?(tid) : @borders.find{|set| set.include?(tid)} == nil
            # Populate this tile as part of the same region
            @map[x,y-1].regionid = id
            # Evaluate its neighbors next time
            open_set.push([x,y-1])
          end
        # Tile is assigned to a different region than the one currently being made
        elsif rid != id
          check_for_bridge_tiles($game_map.get_tile(x,y).id, $game_map.get_tile(x,y-1).id, id, rid)
          @regions[rid].add_border(id)
          @regions[id].add_border(rid)
        end
      end
      # Check down
      if y+1 < $game_map.height
        rid = @map[x,y+1].regionid
        # This tile is not part of a region yet
        if rid == 0
          # Get neighboring tile's ID
          tid = $game_map.get_tile(x,y+1).id
          # If defining a border, check if tile is part of the border set.
          # Otherwise, check that the tile is not part of any border set.
          if !border.nil? ? border.include?(tid) : @borders.find{|set| set.include?(tid)} == nil
            # Populate this tile as part of the same region
            @map[x,y+1].regionid = id
            # Evaluate its neighbors next time
            open_set.push([x,y+1])
          end
        # Tile is assigned to a different region than the one currently being made
        elsif rid != id
          check_for_bridge_tiles($game_map.get_tile(x,y).id, $game_map.get_tile(x,y+1).id, id, rid)
          @regions[rid].add_border(id)
          @regions[id].add_border(rid)
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
  def check_for_bridge_tiles(tile_id, neighbor_tile_id, region_id, neighbor_id)
    # Check if either of these tiles are a "bridging" tile between regions
    v1 = @vital_landmarks.include?(tile_id)
    v2 = @vital_landmarks.include?(neighbor_tile_id)
    if v1 || v2
      # What is the bridge between them?
      tid = v1 ? tile_id : neighbor_tile_id
      # Add this tile along with what region it borders
      @regions[region_id].add_bridge(tid, neighbor_id)
      @regions[neighbor_id].add_bridge(tid, region_id)
    end
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
        unit.ai.influence = calc_unit_influence(unit)
        
    #    p unit.class, unit.ai.influence
        # For each range this unit can occupy/attack
        @locations.flatten.compact.each{|loc|
          # Push unit into its army influence list
          @map[loc.x,loc.y].units_in_range[unit.army.id-1].push(unit)
          # Assign the influence at this current location if better
          
                            #TESTING
          #if unit.ai.influence > @map[loc.x,loc.y].unit_infl[unit.army.id-1]
            @map[loc.x,loc.y].unit_infl[unit.army.id-1] += unit.ai.influence
          #end
        }
      end
      # Checking for property influence
      tile = $game_map.get_tile(x,y)
      if tile.is_a?(Property)
        if tile.army == 0
          @map[x,y].nprop_infl = tile.ai_value
        else
          @map[x,y].prop_infl[tile.army.id-1] = tile.ai_value
        end
      end
    end
    end
    # Generate influence map values
    generate_inf_values
    
    puts Time.now - t
  end
  #-----------------------------------------------------------------------------
  def draw_infl
    @sprites.each{|s| s.bitmap.dispose; s.dispose} unless @sprites.nil?
    @sprites = []
    highest_value = 0
    $maxy = 500 if $maxy.nil?
    for y in 0...$game_map.height
      for x in 0...$game_map.width
        player = @map[x,y].unit_infl[0] + @map[x,y].prop_infl[0]
        enemy  = @map[x,y].unit_infl[1] + @map[x,y].prop_infl[1]
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
    p = 0
    
    if unit.ammo > 0
      DamageChart::PriDamage[unit.unit_type].each{|a|
        if a >= 25
          p += 1
          if a >= 50
            p += 1
            if a >= 75
              p += 1
              if a >= 100
                p += 2
              end
            end
          end
        end
      }
    end
    DamageChart::SecDamage[unit.unit_type].each{|a|
      if a >= 25
        p += 1
        if a >= 50
          p += 1
          if a >= 75
            p += 1
            if a >= 100
              p += 2
            end
          end
        end
      end
    }
    
    
    attack = [p, 0].compact.max
    attack += unit.can_capture ? 25 : 0
    attack += unit.can_supply ? 5 : 0
    attack += unit.can_carry ? 15 : 0
    #attack = attack * unit.unit_hp / 10
    
    range = unit.max_range == 1 ? unit.move + 1 : unit.max_range
    cost = unit.cost / 100.0
    
    unit.ai.base_influence = (attack * range + cost).to_i / 5
    return (attack * unit.unit_hp / 10 * range + cost).to_i / 5
  end
  #-----------------------------------------------------------------------------
  def generate_inf_values

    x, y = 0, 0
    while y < $game_map.height
      while x < $game_map.width
        $game_map.army.each_index{|i| #next if $game_map.army[i].nil?
          @map[x, y].unit_infl[i] = find_uinf_value(x, y, -1, i)
          @map[x, y].prop_infl[i] = find_pinf_value(x, y, -1, i)
        }
        @map[x, y].nprop_infl = find_npinf_value(x, y, -1)
        x+=1
      end
      x=0
      y+=1
    end
    
    x, y = $game_map.width-1, $game_map.height-1
    while y >= 0
      while x >= 0
        $game_map.army.each_index{|i| #next if $game_map.army[i].nil?
          @map[x, y].unit_infl[i] = find_uinf_value(x, y, 1, i)
          @map[x, y].prop_infl[i] = find_pinf_value(x, y, 1, i)
        }
        @map[x, y].nprop_infl = find_npinf_value(x, y, 1)
        x-=1
      end
      x=$game_map.width-1
      y-=1
    end
    
  end
  #-----------------------------------------------------------------------------
  def find_uinf_value(x, y, dir, army_id)

    a, b = 0, 0
    if (x+dir).between?(0,$game_map.width-1)
      a = @map[x + dir, y].unit_infl[army_id]
    end
    
    if (y+dir).between?(0,$game_map.height-1)
      b = @map[x, y + dir].unit_infl[army_id]
    end

    best = [[a,b].max - 25, 0].max
    return [@map[x, y].unit_infl[army_id], best].max

  end
  #-----------------------------------------------------------------------------
  def find_pinf_value(x, y, dir, army_id)
    
    a, b = 0, 0
    if (x+dir).between?(0,$game_map.width-1)
      a = @map[x + dir, y].prop_infl[army_id]
    end
    
    if (y+dir).between?(0,$game_map.height-1)
      b = @map[x, y + dir].prop_infl[army_id]
    end
    
    best = [[a,b].max - 25, 0].max
    return [@map[x, y].prop_infl[army_id], best].max
  end
  #-----------------------------------------------------------------------------
  def find_npinf_value(x, y, dir)
    a, b = 0, 0
    if (x+dir).between?(0,$game_map.width-1)
      a = @map[x + dir, y].nprop_infl
    end
    
    if (y+dir).between?(0,$game_map.height-1)
      b = @map[x, y + dir].nprop_infl
    end
    
    best = [[a,b].max - 25, 0].max
    return [@map[x, y].nprop_infl, best].max
  end
  #-----------------------------------------------------------------------------
  
  def set_best_move(move)
    if @best_move[0] < move[0]
      @best_move = move
    end
  end
  #-----------------------------------------------------------------------------
  def determine_best_move(army_id)
    t = Time.now
    
    @best_move = [-99999, nil]
    
    set_best_move(best_move_capture(army_id))
    if @best_move[1] == nil
      set_best_move(best_move_attack(army_id))
      if @best_move[0] > 0
        set_best_move(best_move_moving(army_id))
      end
    end
    
=begin
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
=end
    puts Time.now - t
    u = @best_move.delete_at(1)
    p [u.class, u.x, u.y] unless u.nil?
    p @best_move
  end
  #-----------------------------------------------------------------------------
 
  def best_move_moving(army_id)
    best_move = [-9999, nil]
    units = $game_map.army[army_id].units.find_all{|unit| !unit.acted}
    return best_move if units.size == 0
    units.sort!{|a, b| a.unit_hp <=> b.unit_hp}
    units.reverse!
    
    units.each{|unit|
      # This unit should move towards the closest, most vulnerable property
      if unit.can_capture
        unit.ai.move_range.flatten.compact.each{|pos|
          influenceTile = @map[pos.x, pos.y]
          move_value = influenceTile.max_prop_infl(army_id) 
          move_value += influenceTile.nprop_infl 
          move_value += influenceTile.vulnerable_map(army_id)
          if move_value > best_move[0]
            best_move = [move_value, unit, pos.x, pos.y, 'move']
          end
        }
      end
      # This unit should move towards the action but staying out of attack range
      if unit.can_attack?
        # Direct combat should approach without much fear from attacks
        if unit.max_range == 1
          unit.ai.move_range.flatten.compact.each{|pos|
            influenceTile = @map[pos.x, pos.y]
            highest_counter = 0
            influenceTile.all_units_in_range(army_id).each{|enemy|
              highest_counter = [enemy.fire(DMG_AI, unit)[0], highest_counter].max
            }
            move_value = unit.ai.base_influence * ((unit.health - highest_counter + 9) / 10) / 10
            #move_value += influenceTile.tension_map(army_id)
            move_value += influenceTile.max_unit_infl(army_id)
            if move_value > best_move[0]
              best_move = [move_value, unit, pos.x, pos.y, 'move']
            end
            
          }
        else # Indirects should approach without potential counters
          $scene.calc_pos(unit, "move").flatten.compact.each{|pos|
            influenceTile = @map[pos.x, pos.y]
            highest_counter = 0
            influenceTile.all_units_in_range(army_id).each{|enemy|
              highest_counter = [enemy.fire(DMG_AI, unit)[0], highest_counter].max
            }
            move_value = unit.ai.base_influence * ((unit.health - highest_counter + 9) / 10) / 10
           # move_value += influenceTile.tension_map(army_id)
            move_value += influenceTile.max_unit_infl(army_id)
            #move_value -= influenceTile.all_units_in_range(army_id).size
            if move_value > best_move[0]
              best_move = [move_value, unit, pos.x, pos.y, 'move']
            end
          }
        end
      end
    }
    
    return best_move
    
  end
  
  #-----------------------------------------------------------------------------

  def best_move_attack(army_id)
    best_move = [-9999, nil]
    # Collect units that can attack
    units = $game_map.army[army_id].units.find_all{|unit| unit.can_attack? && !unit.acted}
    return best_move if units.size == 0
    
    units.sort!{|a, b| a.unit_hp <=> b.unit_hp}
    units.reverse!
    
    units.each{|unit|
      # Direct combat unit
      if unit.max_range == 1
        # Get move range
        unit.ai.move_range = $scene.calc_pos(unit, "move")
        x, y = unit.x, unit.y
        # Check each move range tile
        unit.ai.move_range.flatten.compact.each{|pos|
          # First check that this spot isn't already occupied by another allied unit
          ally_unit = $game_map.get_unit(pos.x,pos.y)
          next if ally_unit != unit
          # Temporarily assign the unit this location
          unit.x, unit.y = pos.x, pos.y
          # Get tiles directly around it
          $scene.calc_pos(unit, "direct").flatten.compact.each{|target|
            enemy_unit = $game_map.get_unit(target.x, target.y)
            next enemy_unit.nil? || enemy_unit.army == unit.army
            # Calculate potential damage
            damages = unit.fire(DMG_AI, enemy)
            enemy_value = enemy_unit.ai.base_influence * ((enemy_unit.health - damages[0] + 9) / 10) / 10
            player_value = unit.ai.base_influence * ((unit.health - damages[1] + 9) / 10) / 10
            # Is the damage done to the enemy significant enough
            if enemy_value <= player_value
              highest_counter = 0
              # Check enemy influence at this spot
              @map[pos.x, pos.y].all_units_in_range(army_id).each{|enemy|
                next unless enemy.can_attack?(unit)
                highest_counter = [enemy.fire(DMG_AI, unit)[0], highest_counter].max
              }
              attack_value = (player_value * ((unit.health - highest_counter + 9) / 10) / 10) - enemy_value
              if attack_value > best_move[0]
                best_move = [attack_value, unit, pos.x, pos.y, 'fire', target.x, target.y]
              end
            end
          }
        }
        # Revert unit's original location
        unit.x, unit.y = x,y
      else
        unit.ai.attack_range = $scene.calc_pos(unit, "attack")
        
        player_value = unit.ai.base_influence * unit.unit_hp / 10
        best_enemy_value = 0
        targetloc = [-1,-1]
        
        # Check each attack range tile
        unit.ai.attack_range.flatten.compact.each{|target|
          enemy_unit = $game_map.get_unit(target.x, target.y)
          next enemy_unit.nil? || enemy_unit.army == unit.army
          # Calculate potential damage
          damages = unit.fire(DMG_AI, enemy)
          enemy_value = enemy_unit.ai.base_influence * ((enemy_unit.health - damages[0] + 9) / 10) / 10
          if enemy_value > best_enemy_value
            best_enemy_value = enemy_value
            targetloc = [target.x, target.y]
          end
          
        }
        enemy_value = best_enemy_value
        
        highest_counter = 0
        # Check enemy influence at this spot
        @map[unit.x, unit.y].all_units_in_range(army_id).each{|enemy|
          next unless enemy.can_attack?(unit)
          highest_counter = [enemy.fire(DMG_AI, unit)[0], highest_counter].max
        }
        attack_value = (player_value * ((unit.health - highest_counter + 9) / 10) / 10) - enemy_value
        if attack_value > best_move[0]
          best_move = [attack_value, unit, unit.x, unit.y, 'fire', targetloc[0], targetloc[1]]
        end
      end
    }
    
    return best_move
    
  end
  
  #-----------------------------------------------------------------------------
  def best_move_capture(army_id)
    # Get all available units that can capture
    units = $game_map.army[army_id].units.find_all{|unit| unit.can_capture && !unit.acted}
    return [-9999, nil] if units.size == 0
    
    units.sort!{|a, b| a.unit_hp <=> b.unit_hp}
    units.reverse!
    
    # For each of those units
    units.each{|unit|
      # Remove all potential properties to capture from memory
      unit.ai.capture_list.clear
      # Continue capturing if capturing
      return [9999, unit, unit.x, unit.y, 'capt'] if unit.capturing
      # Get unit's move ranges
      unit.ai.move_range = $scene.calc_pos(unit, "move")
      # Check for properties within unit's move range
      unit.ai.move_range.flatten.compact.each{|pos|
        # Is this move spot an unowned property tile?
        otherunit = $game_map.get_unit(pos.x,pos.y)
        tile = $game_map.get_tile(pos.x,pos.y)
        if otherunit.nil? && tile.is_a?(Property) && tile.army != unit.army
          distance = (unit.x - pos.x).abs + (unit.y - pos.y).abs
          value = tile.ai_value + distance * 50 + (tile.army != 0 ? 1000 : 0)
          unit.ai.capture_list.push([pos.x, pos.y, value])
        end
      }
    }
    highest_hp = units[0].unit_hp
    # Collect units that have the highest HP and have capture options
    unit_choices = units.find_all{|unit| !unit.ai.capture_list.empty? && unit.unit_hp == highest_hp}

    return [-9999, nil] if unit_choices.size == 0
    # Now collect the units with lowest capture options
    unit_choices.sort!{|a,b| a.ai.capture_list.size <=> b.ai.capture_list.size}
    
    least_options = unit_choices[0].ai.capture_list.size
    best_move = [-9999, nil]
    # Now evaluate best possible move
    unit_choices.each{|unit|
      break if unit.ai.capture_list.size > least_options
      unit.ai.capture_list.each{|option|
        if option[2] > best_move[0]
          best_move = [option[2], unit, option[0], option[1], 'capt']
        end
      }
    }
    
    return best_move

  end
  #-----------------------------------------------------------------------------
  
  
  
end






#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
class InfluenceData
  attr_accessor :unit_infl, :prop_infl, :inf_value, :nprop_infl, :units_in_range,
                :regionid
  
  def initialize
    @unit_infl = Array.new(4, 0)
    @prop_infl = Array.new(4, 0)
    @nprop_infl = 0
    
    @units_in_range = [[],[],[],[]]
    @inf_value = [0,0,0,0]
    
    @regionid = 0
  end
  
  def reset
    @unit_infl.each_index{|i| @unit_infl[i] = 0}
    @prop_infl.each_index{|i| @prop_infl[i] = 0}
    @nprop_infl = 0
    
    @units_in_range.each{|a| a.clear}
    @inf_value.each_index{|i| @inf_value[i] = 0}
  end
  
  def max_prop_infl(army_id)
    best = 0
    for i in 0..3
      next if army_id == i
      best = [@prop_infl[i], best].max
    end
    return best
  end
  
  def max_unit_infl(army_id)
    best = 0
    for i in 0..3
      next if army_id == i
      best = [@unit_infl[i], best].max
    end
    return best
  end
  
  def all_units_in_range(army_id)
    return @units_in_range.clone.delete_at(army_id)
  end
  
  def influence_map(army_id)
    return @unit_infl[army_id] + @prop_infl[army_id] - 
    (max_unit_infl(army_id) + max_prop_infl(army_id))
  end
  
  def tension_map(army_id)
    return max_unit_infl(army_id) + max_prop_infl(army_id) + 
    @unit_infl[army_id] + @prop_infl[army_id]
  end
  
  def vulnerable_map(army_id)
    return tension_map(army_id) - influence_map(army_id).abs
  end

end



