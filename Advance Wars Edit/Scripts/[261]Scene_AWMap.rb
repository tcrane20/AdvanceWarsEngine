=begin
____________________
 Scene_AWMap        \_____________________________________________________________
 
 Main scene that the game takes place on. Currently is just a modified RPG Maker
 class, but I might need to make it its own class one day. I should also
 consider breaking up the script to make finding certain sections easier, such
 as putting all the phases in one file and the AI in another.
 
 Notes:
 * Should still be able to use Event Commands to an extent. I'll probably forgo
 allowing the developer to use things like "Change Party Member", but things
 like "Screen Tone", "Play SE", "Show Message", and maybe even "Move Route" are
 still helpful.
 * In its current state, VERY UNFRIENDLY to save games. Somehow reduce the
 number of variables needed for this class.
 
 Updates:
 - 11/29/14
   + Overhaul in progress
   + Removed old methods, including viewing_ranges, which is still used by a few
     classes (must go and edit those)
 - 11/08/14
   + Tried using another Tilemap to create the ranges. Slight mod to methods.
   + <find_path> was bugged, drawing paths that defy move costs
 - 04/07/14
   + Modifying <calc_pos> to include AI command. Also cleaning it up. There still
     might be future changes I'll have to add for the guys on the board.
 - 03/14/14
   + Trying out drawing the range sprites on load up to see if speed reduced.
   + Verdict: It helps a lot. Of course, figuring out a good number of sprites
     to initialize will vary for each user.
 
________________________________________________________________________________
=end
class Scene_AWMap
  attr_reader :player, :unit
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    
    @infmap = InfluenceMap.new if $DEBUG
    
    #----------------Initialize Variables----------------
    @wait = 0
    @arrow_path = []
    @outside_of_range = false
    @passed_positions = []
    @phase = 0
    @preturn = 1
    @playing_income_se = false
    #-----------------------------------------------------
    # Determines whose turn it is by using @army(X) values
    @player = $game_map.army[0]
    @player.playing = true
    # Move cursor to starting position
    cursor.x = @player.x
    cursor.y = @player.y
    cursor.visible = false
    # Make message window
    @message_window = Window_Message.new
    
    # Make sprite set (includes the units)
    $spriteset = Spriteset_Map.new
    $spriteset.init_units
    $spriteset.revert_unit_colors
    $spriteset.update
    
    # Transition run
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Mouse update (for window active)
#      Mouse.update_windows
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of sprite set
    $spriteset.dispose
    # Dispose of message window
    @message_window.dispose
    # If switching to title screen
    if $scene.is_a?(Scene_Title)
      # Fade out screen
      Graphics.transition
      Graphics.freeze
    end
  end
  

  #-----------------------------------------------------------------------------
  # * Process_Movement : Called when unit is about to move
  #-----------------------------------------------------------------------------
  def process_movement
    # Move the cursor back to the selected unit
    proc = Proc.new{@unit.selected = false
                    @unit.sprite.move(@passed_positions.clone)
                    @unit.stop_capture if @passed_positions.size != 0
                    @passed_positions = []}
    cursor.add_move_action(@unit.x, @unit.y, proc, 0, nil, true)
    # Delete the arrow path graphics and move-range tiles
    @arrow_path.each{|a| a.dispose}
    @arrow_path = []
    remove_ranges
    # Disable input, proceed to moving unit
    cursor.disable_input = true
    @phase = 4
  end
  #-----------------------------------------------------------------------------
  # * determine_unit_commands : Checks what commands the unit can perform
  #-----------------------------------------------------------------------------
  def determine_unit_commands
    commands = [] # Shall push all the commands into this variable
    
    # If the cursor is choosing a spot where a different unit exists (ignores hidden)
    other_unit = $game_map.get_unit(*@command.move, false)
    if other_unit != nil and other_unit != @unit
      # If the unit is the same army type
      if other_unit.army == @unit.army
        # If units can join with each other
        if @unit.can_join?(other_unit)
          commands.push("Join")
        # If unit can be loaded into this other unit
        elsif other_unit.carry_capability(@unit)
          commands.push("Load")
        end
      end
      # Because this unit is ending its turn on another unit, the other commands
      # like Fire, Capture, and Wait do not need to be evaluated
      return commands
    end
    
    # If this unit can attack another unit directly
    if @unit.max_range == 1 and (@unit.ammo > 0 or @unit.secondary)
      ranges = calc_pos(unit, "direct", *@command.move)
      ranges.flatten.compact.each{|r|
        # Continue block if a valid tile to attack
        next unless valid?(r.x, r.y)
        # Get the unit at this spot
        u = $game_map.get_unit(r.x, r.y, false)
        # If no unit exists at this spot
        if !u.is_a?(Unit)
          tile = $game_map.get_tile(r.x, r.y)
          # If this is a tile that can be destroyed
          if tile.is_a?(Structure) and tile.hp > 0 and @unit.can_attack?(tile)
            commands.push("Fire")
            break
          end
          # If enemy unit (will need edit for allied armies)
        elsif u.army != @unit.army and @unit.can_attack?(u)
          commands.push("Fire")
          break
        end
      }
    # If this unit can attack indirectly (and didn't move)
    elsif @unit.max_range > 1 and (@unit.ammo > 0 or @unit.secondary) and
    unit == $game_map.get_unit(*@command.move)
      # Get ranges by calling calc_pos. Then evaluate each spot.
      # If it finds an enemy, push "Fire". Else, push "Fire " (can't fire).
      ranges = calc_pos(unit, "attack")
      ranges.flatten.compact.each{|r|
        next unless valid?(r.x, r.y)
        u = $game_map.get_unit(r.x, r.y, false)
        # If a unit doesn't exist at this spot
        if !u.is_a?(Unit)
          tile = $game_map.get_tile(r.x, r.y)
          if tile.is_a?(Structure) and tile.hp > 0 and @unit.can_attack?(tile)
            commands.push("Fire")
            break
          end
        elsif u.army != @unit.army and @unit.can_attack?(u)
          commands.push("Fire")
          break
        end
      }
      # Couldn't find a valid target--"Unable to Fire" command is added
      commands.push("Fire ") if !commands.include?("Fire")
    end
    
    # If this unit can capture a building
    tile = $game_map.get_tile(*@command.move)
    if @unit.can_capture and tile.is_a?(Property)
      # If this is a missile silo
      if tile.id == TILE_SILO
        commands.push("Launch") unless tile.launched
        # If this is a normal property
      else
        commands.push("Capt") if tile.army != unit.army
      end
    end
    
    # If unit is holding another unit and can drop it
    if @unit.holding_units.size > 0 and @unit.valid_drop_spot(*@command.move)
      units_nearby = $game_map.get_nearby_units(*@command.move)
      tiles_nearby = $game_map.get_nearby_tiles(*@command.move)
      for u in 0...@unit.holding_units.size
        held_unit = @unit.holding_units[u]
        for i in 0...units_nearby.size
          # If the space is empty or if the unit in question is the same as the one
          # being given orders right now
          if units_nearby[i].nil? or units_nearby[i] == @unit
            if @unit.test_drop_tile(tiles_nearby[i], held_unit)
              commands.push("Drop")  if u == 0
              commands.push("Drop ") if u == 1
              break
            end
          end
        end
      end
    end
    
    # If this unit can supply other units
    if @unit.can_supply
      # Get surrounding units
      units_nearby = $game_map.get_nearby_units(*@command.move)
      units_nearby.each{|u|
        # If the space is empty
        next unless u.is_a?(Unit)
        # If the unit is of the same army and has low supplies
        if u != @unit and u.army == @unit.army and u.need_supplies
          commands.push("Supply")
          break
        end
      }
    end
    
    # If unit can dive or hide
    if @unit.can_dive or @unit.can_hide
      if @unit.hiding
        commands.push("Surface") if @unit.can_dive
        commands.push("Appear") if @unit.can_hide
      else
        commands.push("Dive") if @unit.can_dive
        commands.push("Hide") if @unit.can_hide
      end
    end
    
    # Push 'Wait' by default, unless 'Join' or 'Load' is possible
    commands.push("Wait")
    return commands
  end
  #-----------------------------------------------------------------------------
  # * Update Route : Helps determine what arrow path to draw when moving units
  #-----------------------------------------------------------------------------
  def update_player_route
    #@passed_positions = []
    ### The cursor was located outside of the highlighted tiles
    if @outside_of_range
      @outside_of_range = false
      # The cursor moves back into the range, and over a spot where arrow was drawn
      result = false
      @passed_positions.each_index{|index|
        path = @passed_positions[index]
        if [path.x,path.y] == [cursor.x,cursor.y]
          result = index
          break
        end
      }
      # It found the spot where the arrow was drawn
      if result
        @passed_positions = @passed_positions[0, result+1]
      # If moved back into range and over the unit's location
      elsif [cursor.x,cursor.y] == [@unit.x, @unit.y]
        @passed_positions = []
        # If the cursor moves back into range but not where an arrow was drawn
      elsif @positions[cursor.x][cursor.y].is_a?(MoveTile)
        # See if can extend current path to here
        added_path = extend_path(@unit, @passed_positions, [cursor.x,cursor.y])
        # If possible to extend path, do so
        if added_path != false
          @passed_positions += added_path
        else 
          # Generate new path
          @passed_positions = find_path(@positions, 
                              @positions[@unit.x][@unit.y],
                              @positions[cursor.x][cursor.y])
        end
      # Did not move back in range; still outside                      
      else
        @outside_of_range = true
      end
      
      
    else
      ### If position player moves over was already passed over
      result = false
      @passed_positions.each_index{|index|
        path = @passed_positions[index]
        if [path.x,path.y] == [cursor.x,cursor.y]
          result = index
          break
        end
      }
      if result
        @passed_positions = @passed_positions[0, result+1]
        ### If position is outside of available positions...
      elsif !@positions[cursor.x][cursor.y].is_a?(MoveTile)
        # Activate switch to tell game player is out of move range
        @outside_of_range = true
        ### If the cursor is anywhere in the range EXCEPT on the selected unit
      elsif [cursor.x,cursor.y] != [@unit.x, @unit.y]
        # See if can extend current path to here
        added_path = extend_path(@unit, @passed_positions, [cursor.x,cursor.y])
        # If possible to extend path, do so
        if added_path != false
          @passed_positions += added_path
        else 
          # Generate new path
          @passed_positions = find_path(@positions, 
                              @positions[@unit.x][@unit.y],
                              @positions[cursor.x][cursor.y])
        end
        ### Else player is back to the unit's position
      else
        # Reset all stored values (starting fresh)
        @passed_positions = []
      end
    end
    draw_route unless @outside_of_range
  end
  #===========================================================================
  # Check if user's drawn path can reach cursor's location and thereby extend
  # the drawing of the path. If possible, returns array of MoveTiles needed to
  # accomplish the task. Otherwise, returns false.
  #===========================================================================
  def extend_path(unit, path, target)
    return false if path == []
    # Calculate current path's cost
    path_cost = 0
    path.each{|movetile| path_cost += movetile.cost }
    # How many move points does this unit have left
    remaining_moves = [unit.move, unit.fuel].min - path_cost
    # Number of tiles current path is away from target
    distance = (path[-1].x - target[0]).abs + (path[-1].y - target[1]).abs
    # If too many tiles away, current path cannot possibly extend to reach it
    if distance > remaining_moves then return false end
    # Setup data
    cost_limit = 100 # Stops evaluating any further when no more tiles have this cost or below
    positions = []
    for i in 0...$game_map.width
      positions[i] = []
    end
    path.each{|movetile| positions[movetile.x][movetile.y] = 0 } # Ensures that current path and unit's position
    positions[unit.x][unit.y] = 0                                # are not considered when extending path (i.e. no overlap)
    positions[path[-1].x][path[-1].y] = path[-1] # Except for last tile in path
    evaluate = {}
    evaluate[path[-1].total_cost] = [[path[-1].x, path[-1].y]]
    for i in path[-1].total_cost+1...unit.move
      evaluate[i] = []
    end
    # While tiles still need to be evaluated
    while evaluate.size > 0
          # Get key corresponding to the tile with the lowest cost so far to be evaluated
          lowest_cost_key = evaluate.keys.sort.shift
          # Get evaluated tile x/y
          t_x, t_y = evaluate[lowest_cost_key].shift
          # No more spaces to evaluate despite not going max range
          break if t_x.nil?
          
          # If tile south can be moved to and not yet checked
          if unit.passable?(t_x, t_y+1) && positions[t_x][t_y+1].nil?
            # Get move cost of tile
            c = (unit.army.officer.perfect_movement ? 1 : $game_map.get_tile(t_x,t_y+1).move_cost(unit))
            # Add onto this cost with the total cost it takes to get there
            c_total = lowest_cost_key + c
            # If cost is less than move range
            if c_total <= unit.move
              # If distance from this tile to target is too far to reach now
              if (t_x - target[0]).abs + (t_y+1 - target[1]).abs > unit.move - c_total
                # Add dummy to positions to prevent evaluating it in future
                positions[t_x][t_y+1] = 0
              else
                # Add tile as possible move spot
                positions[t_x][t_y+1] = MoveTile.new(t_x, t_y+1, c, c_total)
                # If not expend all movement, add this tile to be evaluated later
                if c_total < unit.move
                  evaluate[c_total].push([t_x, t_y+1])
                end
              end
            end
          end
          
          # If tile north can be moved to and not yet checked
          if unit.passable?(t_x, t_y-1) && positions[t_x][t_y-1].nil?
            # Get move cost of tile
            c = (unit.army.officer.perfect_movement ? 1 : $game_map.get_tile(t_x,t_y-1).move_cost(unit))
            # Add onto this cost with the total cost it takes to get there
            c_total = lowest_cost_key + c
            # If cost is less than move range
            if c_total <= unit.move
              # If distance from this tile to target is too far to reach now
              if (t_x - target[0]).abs + (t_y-1 - target[1]).abs > unit.move - c_total
                # Add dummy to positions to prevent evaluating it in future
                positions[t_x][t_y-1] = 0
              else
                # Add tile as possible move spot
                positions[t_x][t_y-1] = MoveTile.new(t_x, t_y-1, c, c_total)
                # If not expend all movement, add this tile to be evaluated later
                if c_total < unit.move
                  evaluate[c_total].push([t_x, t_y-1])
                end
              end
            end
          end
          
          # If tile east can be moved to and not yet checked
          if unit.passable?(t_x+1, t_y) && positions[t_x+1][t_y].nil?
            # Get move cost of tile
            c = (unit.army.officer.perfect_movement ? 1 : $game_map.get_tile(t_x+1,t_y).move_cost(unit))
            # Add onto this cost with the total cost it takes to get there
            c_total = lowest_cost_key + c
            # If cost is less than move range
            if c_total <= unit.move
              # If distance from this tile to target is too far to reach now
              if (t_x+1 - target[0]).abs + (t_y - target[1]).abs > unit.move - c_total
                # Add dummy to positions to prevent evaluating it in future
                positions[t_x+1][t_y] = 0
              else
                # Add tile as possible move spot
                positions[t_x+1][t_y] = MoveTile.new(t_x+1, t_y, c, c_total)
                # If not expend all movement, add this tile to be evaluated later
                if c_total < unit.move
                  evaluate[c_total].push([t_x+1, t_y])
                end
              end
            end
          end
          
          # If tile east can be moved to and not yet checked
          if unit.passable?(t_x-1, t_y) && positions[t_x-1][t_y].nil?
            # Get move cost of tile
            c = (unit.army.officer.perfect_movement ? 1 : $game_map.get_tile(t_x-1,t_y).move_cost(unit))
            # Add onto this cost with the total cost it takes to get there
            c_total = lowest_cost_key + c
            # If cost is less than move range
            if c_total <= unit.move
              # If distance from this tile to target is too far to reach now
              if (t_x-1 - target[0]).abs + (t_y - target[1]).abs > unit.move - c_total
                # Add dummy to positions to prevent evaluating it in future
                positions[t_x-1][t_y] = 0
              else
                # Add tile as possible move spot
                positions[t_x-1][t_y] = MoveTile.new(t_x-1, t_y, c, c_total)
                # If not expend all movement, add this tile to be evaluated later
                if c_total < unit.move
                  evaluate[c_total].push([t_x-1, t_y])
                end
              end
            end
          end
          
          # If found target spot, set cost limit for evaluation
          if cost_limit == 100 && 
          positions[target[0]][target[1]] != 0 && positions[target[0]][target[1]] != nil
            cost_limit = lowest_cost_key
          end
          
          # If this key value no longer has any tiles left to evaluate, remove it
          if evaluate[lowest_cost_key] == []
            evaluate.delete(lowest_cost_key)
            # If found target spot and reached evaluation limit, stop looping
            break if cost_limit == lowest_cost_key
          end
          
    end # END OF while
    
    # Path to target cannot be reached via extension of current path
    return false if cost_limit == 100
    
    # Find path
    finish = positions[target[0]][target[1]]
    start  = path[path.size-1]
    return find_path(positions, start, finish)#[start.x, start.y], [finish.x, finish.y])
  end
  
  #===========================================================================
  # Finds a path from start to finish using the collection of MoveTiles in
  # positions. start and finish are both MoveTile objects.
  #===========================================================================
  def find_path(positions, start, finish)
    # Will hold MoveTiles that form a path from start to finish
    path = [finish]
    # Get finish tile first so that we can work backwards in making the path
    chosen = finish
    movetile = chosen
    # Endless loop ZOMG
    while true
      t_x, t_y = movetile.x, movetile.y
      # Generate list of tiles surrounding this tile
      surrounding = []
      surrounding.push(positions[t_x][t_y+1]) if valid?(t_x, t_y+1)
      surrounding.push(positions[t_x][t_y-1]) if valid?(t_x, t_y-1)
      surrounding.push(positions[t_x+1][t_y]) if valid?(t_x+1, t_y)
      surrounding.push(positions[t_x-1][t_y]) if valid?(t_x-1, t_y)
      
      surrounding.compact!
      surrounding.delete(0)
      consider = []
      lowest_cost = 99
      # Evaluate surrounding tiles to find lowest cost
      surrounding.each{|tile|
      # If tile has a total move cost that is at least equal to the current best
        if tile.total_cost <= lowest_cost
          # If even lower, remove previous considerations and set new best
          if tile.total_cost < lowest_cost
            consider.clear
            lowest_cost = tile.total_cost
          end
          # Add this tile to be considered
          consider.push(tile)
        end
      }
      # Choose a tile from list
      chosen = consider[rand(consider.size)]
      # Return path if that last tile was the final one
      return path.reverse! if [chosen.x, chosen.y] == [start.x, start.y]
      # Add chosen tile to path
      path.push(chosen)
      # Evaluate this tile next
      movetile = chosen
    end
  end
  #-----------------------------------------------------------------------------
  # * Draw Route : Draws the arrows that represent the unit's movement path
  #-----------------------------------------------------------------------------
  def draw_route
    # Delete all sprites in drawing of path
    @arrow_path.each{|a| a.dispose}
    @arrow_path = []
    
    return if @passed_positions.empty?
    start_pos = [@unit.x, @unit.y]
    new_pos = start_pos
    type = ""
    # Get direction from unit to first tile in path
    last_dir = case [@passed_positions[0].x - @unit.x, @passed_positions[0].y - @unit.y]
              when [0, 1] then 2
              when [-1,0] then 4
              when [1, 0] then 6
              when [0,-1] then 8
              end
    # Loop through path positions, evaluating two elements at a time
    for i in 0...@passed_positions.size
      p1 = @passed_positions[i]
      p1 = [p1.x, p1.y]
      p2 = (@passed_positions[i+1] == nil ? 0 : @passed_positions[i+1])
      if p2.is_a?(MoveTile)
        p2 = [p2.x, p2.y] 
        # Figure out the direction taken to get from p1 to p2
        dir = [p2[0] - p1[0], p2[1] - p1[1]]
        dir = case dir
              when [0, 1] then 2
              when [-1,0] then 4
              when [1, 0] then 6
              when [0,-1] then 8
              end
      else
        dir = 0
      end
      # Evaluate the last direction taken to get to current spot
      case last_dir
      when 2
        new_pos[1] += 1
        type = case dir
        when 0 then "d"
        when 2 then "v"
        when 4 then "ru"
        when 6 then "lu"
        end
      when 4
        new_pos[0] -= 1
        type = case dir
        when 0 then "l"
        when 2 then "ld"
        when 4 then "h"
        when 8 then "lu"
        end
      when 6
        new_pos[0] += 1
        type = case dir
        when 0 then "r"
        when 2 then "rd"
        when 6 then "h"
        when 8 then "ru"
        end
      when 8
        new_pos[1] -= 1
        type = case dir
        when 0 then "u"
        when 4 then "rd"
        when 6 then "ld"
        when 8 then "v"
        end
      end
      last_dir = dir
      @arrow_path.push(Arrow_Sprite.new($spriteset.viewport1, type, new_pos))
    end
  end
  #-----------------------------------------------------------------------------
  # * Calc_Pos - Find what tiles to highlight to determine range
  #-----------------------------------------------------------------------------
  # unit = Class Unit
  # range_max = maximum range that can be achieved
  # range_min = minimum "                         "
  # type = what tiles are we going to work on?
  #   >> "move"   - Move range
  #   >> "attack" - Attack range
  #   >> "direct" - 4 tiles around the unit
  #    >> "vision" - Unit's vision range
  #   >> "ai"     - Move + Attack ranges for direct units; Attack for indirect
  # x , y = If wanting to get tiles from a specific spot and not a unit's x/y
  #-----------------------------------------------------------------------------
  def calc_pos(unit, type = "move", x = nil, y = nil)
    # If parameters x and y are not set up, use unit's x and y variables
    if x.nil? or y.nil?
      x = unit.x
      y = unit.y
    end
    # Stores all the x-y coordinates of possible spots
    positions = Array2D.new($game_map.width, $game_map.height)
    # If want move range OR requesting attack range of direct combat
    if type == "move" or 
    ((type == "attack" or type == "ai") and unit.max_range == 1)
      # Sets maximum move range based on remaining fuel
      range_max = (unit.fuel < unit.move ? unit.fuel : unit.move )
      # Adds starting position
      positions[x][y] = MoveTile.new(x,y,0,0)
      # If can move further (not immobile)
      if range_max > 0
        # New hash that stores move costs and locations to be checked. Format:
        # Current Move Cost => Array of tile coordinates that need to be checked
        need_evaluation = {}
        # Set starting position to cost of zero
        need_evaluation[0] = [[x,y]]
        # Create all the move costs possible by this unit (i.e. max movement - 1)
        for i in 1...range_max
          need_evaluation[i] = []
        end
        
        # While tiles still need to be evaluated for potential move spaces
        while need_evaluation.size > 0
          # Get key corresponding to the tile with the lowest cost so far to be evaluated
          lowest_cost_key = need_evaluation.keys.sort.shift
          # Get next evaluated tile x/y
          t_x, t_y = need_evaluation[lowest_cost_key].shift
          # No spaces to evaluate for this move cost?
          if t_x.nil?
            # Remove this move cost key
            need_evaluation.delete(lowest_cost_key)
            # Jump back to start of loop for next available move cost
            next
          end
          
          # If tile south can be moved to
          if positions[t_x,t_y+1].nil? && unit.passable?(t_x, t_y+1)
            # Get move cost of tile
            c = (unit.army.officer.perfect_movement ? 1 : $game_map.get_tile(t_x,t_y+1).move_cost(unit))
            # Add onto this cost with the total cost it takes to get there
            c_total = lowest_cost_key + c
            # If cost is less than move range
            if c_total <= range_max
              # Add tile as possible move spot
              positions[t_x,t_y+1] = MoveTile.new(t_x, t_y+1, c, c_total)
              # If not expend all movement, add this tile to be evaluated later
              if c_total < range_max
                need_evaluation[c_total].push([t_x, t_y+1])
              end
            end
          end
          
          # If tile north can be moved to
          if positions[t_x,t_y-1].nil? && unit.passable?(t_x, t_y-1)
            # Get move cost of tile
            c = (unit.army.officer.perfect_movement ? 1 : $game_map.get_tile(t_x,t_y-1).move_cost(unit))
            # Add onto this cost with the total cost it takes to get there
            c_total = lowest_cost_key + c
            # If cost is less than move range
            if c_total <= range_max
              # Add tile as possible move spot
              positions[t_x,t_y-1] = MoveTile.new(t_x, t_y-1, c, c_total)
              # If not expend all movement, add this tile to be evaluated later
              if c_total < range_max
                need_evaluation[c_total].push([t_x, t_y-1])
              end
            end
          end
          
          # If tile east can be moved to
          if positions[t_x+1,t_y].nil? && unit.passable?(t_x+1, t_y)
            # Get move cost of tile
            c = (unit.army.officer.perfect_movement ? 1 : $game_map.get_tile(t_x+1,t_y).move_cost(unit))
            # Add onto this cost with the total cost it takes to get there
            c_total = lowest_cost_key + c
            # If cost is less than move range
            if c_total <= range_max
              # Add tile as possible move spot
              positions[t_x+1,t_y] = MoveTile.new(t_x+1, t_y, c, c_total)
              # If not expend all movement, add this tile to be evaluated later
              if c_total < range_max
                need_evaluation[c_total].push([t_x+1, t_y])
              end
            end
          end
          
          # If tile west can be moved to
          if positions[t_x-1,t_y].nil? && unit.passable?(t_x-1, t_y)
            # Get move cost of tile
            c = (unit.army.officer.perfect_movement ? 1 : $game_map.get_tile(t_x-1,t_y).move_cost(unit))
            # Add onto this cost with the total cost it takes to get there
            c_total = lowest_cost_key + c
            # If cost is less than move range
            if c_total <= range_max
              # Add tile as possible move spot
              positions[t_x-1,t_y] = MoveTile.new(t_x-1, t_y, c, c_total)
              # If not expend all movement, add this tile to be evaluated later
              if c_total < range_max
                need_evaluation[c_total].push([t_x-1, t_y])
              end
            end
          end
          
          # If this move cost no longer has any tiles left to evaluate, remove it
          if need_evaluation[lowest_cost_key] == []
            need_evaluation.delete(lowest_cost_key)
          end
          
        end
        ### END of *** while need_evaluation.size > 0 ***
      end
      ### END of *** if range_max > 0 ***
      
      # If we only wanted move ranges, we are done and can stop here
      if type == "move"
        return positions
      end
    end
    ######### END OF DEFINING MOVEMENT RANGE ##########
    
    # If we want attack, AI, or vision ranges
    if type == "attack" or type == "ai" or type == "vision"
      # Get min and max ranges of unit based on whether we want attack or vision
      range_max = (type == "attack" || type == "ai" ? unit.max_range : unit.vision)
      range_min = (type == "attack" || type == "ai" ? unit.min_range : 0)
      ##### If want attack range and unit is direct type
      if (type == "attack" or type == "ai") and range_max == 1
        # Make copy of possible move positions
        move_positions = positions.clone
        # If we do not want to get AI range
        if type != "ai"
          # Reset positions list into empty 2D array
          positions = Array2D.new($game_map.width, $game_map.height)
        end
        # For each possible move position
        for p in move_positions.flatten.compact
          # Unit exists at this spot, so cannot attack surrounding tiles here
          next unless ($game_map.get_unit(p.x,p.y,false).nil? || type == "ai")
          # Add attack ranges to list if it is a valid spot and doesn't already
          # exist in the list
          positions[p.x - 1,p.y] = MoveTile.new(p.x - 1, p.y) if (valid?(p.x - 1, p.y) && positions[p.x - 1,p.y].nil?)
          positions[p.x + 1,p.y] = MoveTile.new(p.x + 1, p.y) if (valid?(p.x + 1, p.y) && positions[p.x + 1,p.y].nil?)
          positions[p.x,p.y - 1] = MoveTile.new(p.x, p.y - 1) if (valid?(p.x, p.y - 1) && positions[p.x,p.y - 1].nil?)
          positions[p.x,p.y + 1] = MoveTile.new(p.x, p.y + 1) if (valid?(p.x, p.y + 1) && positions[p.x,p.y + 1].nil?)
        end
        # Don't include the spot this unit is on as attackable, unless this is AI
        positions[x][y] = nil if type != "ai"
      ##### If unit is indirect type or we want vision ranges
      else
        # If want vision range, consider unit's spot as seen
        if type == "vision"
          positions[x, y] = MoveTile.new(x, y)
          range_min = 1
        end
        # Calculate ranges in a clockwise direction, radiating outwards
        for r in range_min..range_max
          origin = [unit.x, unit.y-r]
          positions[origin[0],origin[1]] = MoveTile.new(origin[0], origin[1]) if valid?(origin[0], origin[1])
          loop do
            origin[0] += 1
            origin[1] += 1
            positions[origin[0],origin[1]] = MoveTile.new(origin[0], origin[1]) if valid?(origin[0], origin[1])
            break if origin[1] == unit.y
          end
          loop do
            origin[0] -= 1
            origin[1] += 1
            positions[origin[0],origin[1]] = MoveTile.new(origin[0], origin[1]) if valid?(origin[0], origin[1])
            break if origin[0] == unit.x
          end
          loop do
            origin[0] -= 1
            origin[1] -= 1
            positions[origin[0],origin[1]] = MoveTile.new(origin[0], origin[1]) if valid?(origin[0], origin[1])
            break if origin[1] == unit.y
          end
          loop do
            origin[0] += 1
            origin[1] -= 1
            break if origin[0] == unit.x
            positions[origin[0],origin[1]] = MoveTile.new(origin[0], origin[1]) if valid?(origin[0], origin[1])
          end
        end
      end
      # Gets the spots directly next to this unit
    elsif type == "direct"
      locations = [[x, y-1], [x+1, y], [x, y+1], [x-1, y]]
      for spot in locations
        positions[spot[0],spot[1]] = MoveTile.new(spot[0],spot[1]) if valid?(spot[0], spot[1])
      end
    end
    
    return positions
  end
  #--------------------------------------------------------------------------
  # Determines which [x,y] coordinate is best to launch a missile silo
  #--------------------------------------------------------------------------
  def find_best_missile_spot(radius = 2)
    # initialize variables
    total_unit_cost = 0.1
    best_spot       = [-1,-1]
    cost = 0
    # check each spot on map
    for y in 0...$game_map.height
      for x in 0...$game_map.width
        cost = 0
        positions = $game_map.get_spaces_in_area(x,y,radius)
        positions.each{|pos|
          u = $game_map.get_unit(pos[0],pos[1])
          next if u.nil?
          if u.army == @player
            cost -= u.cost * u.unit_hp
          else
            cost += u.cost * u.unit_hp
          end
        }
        # Prefers most cost effective strike
        if cost >= total_unit_cost
          # If this spot is the same results as another spot
          if cost == total_unit_cost
            # Obtain units, if any, at these two spots
            unit_a = $game_map.get_unit(best_spot[0],best_spot[1])
            unit_b = $game_map.get_unit(x,y)
            # If there was no unit at best_spot
            if unit_a.nil?
              best_spot = [x,y]
              total_unit_cost = cost
            else
              # If there is a unit at this current spot
              unless unit_b.nil?
                # If the cost of this unit is more than the 'best_spot' unit
                if unit_a.cost < unit_b.cost
                  best_spot = [x,y]
                  total_unit_cost = cost
                end
              end
            end
          else
            best_spot = [x,y]
            total_unit_cost = cost
          end
        end
      end
    end
    return best_spot
  end
  #--------------------------------------------------------------------------
  # Modify the @positions2 array to remove places that do not satisfy the condition.
  # 'unit' is the unit that must satisfy attack or drop conditions.
  # 0 -> Removes spots that have units on them (i.e. dropping units)
  # 1 -> Keeps spots that have enemy units on them (i.e. firing)
  #--------------------------------------------------------------------------
  def remove_empty_zones(type, unit = nil)
    @positions2.flatten.compact.each{|zone|
      next unless (!zone.nil? && valid?(zone.x,zone.y))
      u = $game_map.get_unit(zone.x, zone.y, false)
      # If unit exists at this location
      if !u.nil?
        # If dropping a unit, and this unit here is the carrying unit
        if u == unit and type == 0
          if @command.action == "Drop"
            held_unit = unit.holding_units[0]
          elsif @command.action == "Drop "
            held_unit = unit.holding_units[1]
          end
          # If this location cannot drop a unit here
          if !unit.test_drop_tile($game_map.get_tile(zone.x,zone.y), held_unit) or @command.drop_loc(0) == [zone.x,zone.y]
            @positions2[zone.x,zone.y] = nil
          end
          next
        # If finding attackable units, and this unit happens to be targetting itself
        elsif u == unit and type == 1
          @positions2[zone.x,zone.y] = nil
          next
        end
        # Unit exists here, so delete spot if type 0
        if type == 0
          @positions2[zone.x,zone.y] = nil
          next
          # Because unit is of same army type, delete spot
        elsif u.army == @player or !unit.can_attack?(u)
          @positions2[zone.x,zone.y] = nil
        end
      else
        # If the tile here can be attacked, keep it
        tile = $game_map.get_tile(zone.x,zone.y)
        if tile.is_a?(Structure) and tile.hp > 0 and unit.can_attack?(tile)
          next
        end
        @positions2[zone.x,zone.y] = nil if type == 1
        # If the unit parameter has a value
        unless unit.nil?
          if @command.action == "Drop"
            held_unit = unit.holding_units[0]
          elsif @command.action == "Drop "
            held_unit = unit.holding_units[1]
          end
          # If this location cannot drop a unit here
          if !unit.test_drop_tile(tile, held_unit) or @command.drop_loc(0) == [zone.x,zone.y]
            @positions2[zone.x,zone.y] = nil
          end
        end
      end
    }
  end
  #--------------------------------------------------------------------------
  # Generates a list of units in @unit's holding_units that can still be dropped
  #--------------------------------------------------------------------------
  def can_drop_list
    # No units to drop
    return false if @unit.holding_units.empty?
    held_units = @unit.holding_units.clone
    @command.target.each{|target| drop_unit = target[2]
      held_units.delete(drop_unit)
    }
    return false if held_units.empty?
    can_be_dropped = []
    # Check surrounding areas for potential drop off locations
    tiles_nearby = calc_pos(@unit, "direct", *@command.move)
    tiles_nearby.flatten.compact.each{|tile|
      break if held_units.empty?
      # Check that a unit is not already being dropped here
      next if @command.target.any?{|drop_spot|
        [drop_spot[0], drop_spot[1]] == [tile.x, tile.y]
      }
      # If no unit here, or if the carrier unit
      unit_here = $game_map.get_unit(tile.x, tile.y)
      if unit_here.nil? || unit_here == @unit
        # Check the held units and see if they can be dropped on this tile
        held_units.each_index{|i| u = held_units[i]
          type = $game_map.get_tile(tile.x, tile.y)
          if @unit.test_drop_tile(type, u)
            # This unit can be dropped, so add to the list and remove from
            # being further evaluated
            can_be_dropped.push(held_units[i])
            held_units[i] = nil
          end
        }
        held_units.compact! # Remove units that may have been added to the list (and replaced with nil)
      end
    }
    # If no units can be dropped, return false; otherwise, return the list
    return (can_be_dropped.empty? ? false : can_be_dropped)
  end
  #--------------------------------------------------------------------------
  # Draw the tiles to show range of attack and move
  # 'type' to draw the correct glowy tiles
  #--------------------------------------------------------------------------
  def draw_ranges(positions, type)
    $spriteset.show_ranges(positions.flatten.compact)
  end
  #--------------------------------------------------------------------------
  # Turns the movement range tiles invisible or visible
  #--------------------------------------------------------------------------
  def remove_ranges
    $spriteset.show_ranges(false)
  end
  #--------------------------------------------------------------------------
  # Delete the arrow sprites drawing the unit path
  #--------------------------------------------------------------------------
  def dispose_arrows
    @arrow_path.each{|a| a.dispose}
    @arrow_path = []
    @passed_positions = []
  end
  #-------------------------------------------------------------------------
  # Valid? - Determines if x,y coordinates are on map
  #-------------------------------------------------------------------------
  def valid?(x, y)
    return (x >= 0 and x < $game_map.width and y >= 0 and y < $game_map.height)
  end
  #-------------------------------------------------------------------------
  # cursor - Easier/logical reading of cursor
  #-------------------------------------------------------------------------
  def cursor
    return $game_player
  end
  #-----------------------------------------------------------------------------
  # Disposes the active window and sets it to nil
  #-----------------------------------------------------------------------------
  def dispose_active_window
    @active_window.dispose
    @active_window = nil
  end
end

