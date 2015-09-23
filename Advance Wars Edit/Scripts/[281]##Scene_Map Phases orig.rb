=begin
__________________
 Scene_Map        \_____________________________________________________________
 
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
 - 11/09/14
   + Cleaning is fun
   + Preturn phase broken up as well as utilizes the cursor actions I created
   + Fixed bug where the army would be routed at the start of battle
 - 11/08/14
   + More clean up; started breaking up blocks of code into sub functions
   + Cursor actions are near perfect; phase 0 benefits a lot
   + Started experimenting with tilemaps to draw the ranges
 - 11/02/14
   + General clean up; can I possibly make dropping 2 units off cleaner?
 - 03/14/14
   + Trying out drawing the range sprites on load up to see if speed reduced.
   + Verdict: It helps a lot. Of course, figuring out a good number of sprites
     to initialize will vary for each user.
________________________________________________________________________________
=end
class Scene_Map
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    $thing.update unless $thing.nil?
    # Gets the cursor's coordinates before processing begins
    @current_cursor_x = cursor.x
    @current_cursor_y = cursor.y
    # Update the map and frame count
    $game_map.update
    # Update any running events
    $game_system.map_interpreter.update
    # Update the player (the cursor) depending on the phase
    cursor.update unless [6].include?(@phase)
    # Update system (timer), screen shakes/tints
    $game_system.update
    $game_screen.update
    # Update sprite set (updates all the graphics on screen like unit or cursor)
    $spriteset.update
    # Reduce wait timer each frame
    @wait -= 1 if @wait > 0
    # Deletes placeholder spots in army units arrays
    unless @preturn == 2
      $game_map.army.each{|army|
        next if army.nil?
        army.cleanup_units
      }
    end
    # If the cursor is forced to move to specific location(s) to perform action(s)
    if cursor.moveto_locations.size > 0
      process_cursor_movement_commands
    else
      update_by_phase
    end
  
  
    # Update message window
    @message_window.update
    # Check if an army has lost battle
    check_for_defeated_armies
    
    # If returning to title screen
    if $game_temp.to_title
      # Change to title screen
      $scene = Scene_Title.new
      return
    end
    # If showing message window
    if $game_temp.message_window_showing
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Moves the cursor to a specified location to perform an action created by
  # a Proc object.
  #--------------------------------------------------------------------------
  def process_cursor_movement_commands
    if cursor.moveto_locations[0] != nil
      # Disable cursor and speed it up
      cursor.visible = false
      cursor.disable_input = true
      cursor.move_speed = 6
      # Move the cursor to the location
      loc_x, loc_y = cursor.moveto_locations[0]
      cursor.slide_to(loc_x, loc_y)
      # If reached destination
      if [cursor.real_x/128, cursor.real_y/128] == cursor.moveto_locations[0]
        # Remove the location from the list
        cursor.moveto_locations[0] = nil
        # Perform special command, if any
        @proc = cursor.moveto_actions.shift
        if @proc != nil
          @proc[0].call unless @proc[0].nil?
          case @proc[1]
          when WAIT_CURSOR_POWER, WAIT_UNIT_POWER 
            if cursor.moveto_actions[0] != nil && cursor.moveto_actions[0][1] == @proc[1]
              wait(12)
            else
              wait(-2)
            end
          else
            wait(@proc[1])
          end
        end
      end
    # Cursor is at its location  
    else
      # Unit is being repaired, deduct funds per frame
      if @making_repairs
        @player_turn.frame_repair(@wait == 0)
      end
      # Do not progress any further until the wait counter is over or animation
      # has finished playing
      return if @wait > 0
      if @wait == -2
        return if $spriteset.animation_end?
      end
      
      @wait = 0
      @proc[2].call if @proc[2] != nil
      cursor.moveto_locations.shift
      if cursor.moveto_locations.size == 0
        cursor.visible = true
        cursor.disable_input = false
        cursor.move_speed = 5
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Checks if an army has been defeated. Removes all existing units and 
  # properties owned by the defeated army
  #--------------------------------------------------------------------------
  def check_for_defeated_armies
    loser_army = $game_map.army.find{|army| next if army.nil? ; army.lost_battle}
    if loser_army != nil
      case loser_army.id
      when 1 then p "Player 1/Orange Star lost"
      when 2 then p "Player 2/Blue Moon lost"
      when 3 then p "Player 3/Green Earth lost"
      when 4 then p "Player 4/Yellow Comet lost"
      end
      # If there are at least 2 armies remaining
      if $game_map.army.count{|x| !x.nil?} > 2
        # If routed
        if loser_army.lost_battle == 1
          while loser_army.owned_props.size > 0
            loser_army.owned_props[0].army = 0
          end
        # If HQ captured
        elsif loser_army.lost_battle == 2
          loser_army.units.each{|unit| unit.destroy}
          # Assign all owned properties to the capturer
          while loser_army.owned_props.size > 0
            loser_army.owned_props[0].army = @player_turn
          end
        end
        # Set this army to nil so it will no longer be evaluated
        $game_map.army[loser_army.id-1] = nil
        # If lost on own turn, then advanced to next player's turn
        @phase = 7 if loser_army == @player_turn
      else
        winner_army = $game_map.army.find{|army| !army.nil?}
        case winner_army.id
        when 1 then p "Player 1/Orange Star wins!"
        when 2 then p "Player 2/Blue Moon wins!"
        when 3 then p "Player 3/Green Earth wins!"
        when 4 then p "Player 4/Yellow Comet wins!"
        end
        # Closes the game...for now
        $scene = nil
      end
    end
  end
  #--------------------------------------------------------------------------
  # Main update method. Depending on what phase it is determines the update
  # routine taken.
  #--------------------------------------------------------------------------
  def update_by_phase
    case @phase
    when 0 then phase_preturn
    when 1 then phase_cursor
    when 2 then phase_command
    when 3 then phase_action
    when 4 then phase_decision
    when 5 then phase_animation
    when 6 then phase_menu
    when 7 then phase_endturn
    end
  end
  #--------------------------------------------------------------------------
  # Phase 0 : Preturn
  #   Performs the daily actions that occur before the player has actual
  #   control of the cursor. This includes daily income, repairs, and fuel
  #   burn (along with destroying them if necessary)
  #--------------------------------------------------------------------------
  def phase_preturn
    case @preturn
    when 1 then preturn_preparations
    when 2 then preturn_dailyfuel
    when 3 then preturn_repair
    when 4 then preturn_unitsupply
    when 5 then preturn_finish
    end
  end
  #--------------------------------------------------------------------------
  # Preturn 1 : Preparations
  #   Resets variables and flags, check for weather changes, gain income...
  #--------------------------------------------------------------------------
  def preturn_preparations
    # Do not process preturn phase until wait timer finishes
    return if @wait > 0
    
    # Disable the units that have a disabled flag
    @player_turn.units.each{|u|
      if u.disabled
        u.acted = true
        u.disabled = false
      end
    }
    # Play the player's CO theme music
    $game_system.bgm_play(@player_turn.officer.name)
    # Turn off COP and SCOP flags
    @player_turn.officer.cop = false
    @player_turn.officer.scop = false
    # Play sound effect if the player's COP/SCOP is full
    if @player_turn.stored_energy == @player_turn.officer.scop_rate
      Config.play_se("superpower")
    elsif @player_turn.stored_energy >= @player_turn.officer.cop_rate and @player_turn.officer.cop_stars != 0
      Config.play_se("power")
    end
    # If there is a weather effect
    if $game_map.current_weather != 'none'
      # Check if need to turn off the current weather
      if $game_map.turn_weather_off(@player_turn)
        $game_map.set_weather('none')
      end
    end
    # Draw the player's officer tag graphic located at the top of the screen (EDIT the way graphic is drawn)
    $spriteset.draw_officer_tag(@player_turn)
    # Adds funds based on properties owned that give income
    @player_turn.earn_daily_income
    # If the player has any units out or if it's day one (EDIT)
    unless @player_turn.units.size == 0
      @unit_index = 0
      # Skip daily fuel consumption on Day 1
      unless $game_map.day == 1
        @preturn = 2
      else
        @preturn = 3
      end
    else
      @preturn = 5
    end
  end
  #--------------------------------------------------------------------------
  # Preturn 2 : Daily Fuel
  #   Burn units' daily fuel. Destroys units that have "crashed" or "sunk".
  #--------------------------------------------------------------------------
  def preturn_dailyfuel
    # The two lines stops processing of this phase if a unit is carrying out
    # its destruction animation. When it finishes, continue the phase.
    @wait = 0 if $spriteset.finished_destruction
    return if @wait == -1
    
    while true
      # Finished running through all the units?
      if @unit_index >= @player_turn.units.size
        @unit_index = 0
        @preturn = 3
        return
      end
      # Depletes daily fuel costs
      unit = @player_turn.units[@unit_index]
      tile = $game_map.get_tile(unit.x, unit.y)
      # If the unit is NOT over a property that can supply this unit, burn fuel
      unit.daily_fuel if !tile.can_repair(unit) 
      @unit_index += 1
      
      if unit.needs_deletion
        wait(-1)
        return
      end
    end
  end
  #--------------------------------------------------------------------------
  # Preturn 3 : Repair
  #   Repairs units standing on owned properties. Also supplies units should
  #   they need it.
  #--------------------------------------------------------------------------
  def preturn_repair
    # If ran through all units
    if @unit_index == @player_turn.units.size
      @preturn = 4
      @unit_index = 0
      return
    end
    # Loop until found a unit to repair
    loop do
      # If no more units, move onto next phase
      if @unit_index == @player_turn.units.size
        @preturn = 4
        @unit_index = 0
        break
      end
      # Holds list of commands size to check if new commands will be added later
      listsize = cursor.moveto_locations.size
      
      unit = @player_turn.units[@unit_index]
      # Advance to next unit in list
      @unit_index += 1
      # Apply daily unit updates
      unit.made_repairs = false
      # Check if unit can be healed
      tile = $game_map.get_tile(unit.x, unit.y)
      # If unit is damaged, not loaded and on a tile that can repair it
      if tile.can_repair(unit) 
        if unit.health < 100 and !unit.loaded 
          Config.play_se("income") unless @playing_income_se
          @playing_income_se = true
          # Move cursor to unit's spot and play repair animation
          proc = Proc.new{unit.sprite.play_animation('repair'); unit.supply}
          wait_time = @player_turn.daily_repair(unit, tile)
          endproc = Proc.new{unit.repair(@player_turn.repair_amount)
                             unit.sprite.stop_loop_animation
                             unit.made_repairs = true
                             @making_repairs = false}
          cursor.add_move_action(unit.x, unit.y, proc, wait_time, endproc)
          @making_repairs = true
        elsif unit.need_supplies
          Config.play_se("income") unless @playing_income_se
          @playing_income_se = true
          proc = Proc.new{unit.sprite.play_animation('supply'); unit.supply}
          wait_time = 30
          endproc = Proc.new{unit.sprite.stop_loop_animation}
          cursor.add_move_action(unit.x, unit.y, proc, wait_time, endproc)
        end
      end
      # If carrying units and can do a special effect
      if unit.holding_units.size > 0 and unit.carry_effect
        Config.play_se("income") unless @playing_income_se
        @playing_income_se = true
        proc = Proc.new{unit.sprite.play_animation('supply')}
        wait_time = 30
        endproc = Proc.new{unit.sprite.stop_loop_animation}
        cursor.add_move_action(unit.x, unit.y, proc, wait_time, endproc)
      end
      # If an action was added to list, break
      break if listsize != cursor.moveto_locations.size
    end # End loop
  end
  #--------------------------------------------------------------------------
  # Preturn 4 : Unit Supply
  #   Checks units that can supply surrounding units. 
  #--------------------------------------------------------------------------
  def preturn_unitsupply
    
    # Loop until a unit that can supply daily is found
    loop do
      unit = @player_turn.units[@unit_index]
      @unit_index += 1
      if unit.can_daily_supply
        # Evaluate nearby units
        units_nearby = $game_map.get_nearby_units(unit.x, unit.y)
        units_nearby.each{|u|
          # Skip if the space is empty
          next unless u.is_a?(Unit)
          # If the unit is of the same army and has low supplies
          if u.army == unit.army and u.need_supplies
            Config.play_se("income") unless @playing_income_se
            @playing_income_se = true
            proc = Proc.new{u.sprite.play_animation('supply'); u.supply}
            wait_time = 30
            endproc = Proc.new{u.sprite.stop_loop_animation}
            cursor.add_move_action(u.x, u.y, proc, wait_time, endproc)
          end
        }
        break
      end
      break if @unit_index == @player_turn.units.size
    end
    # If checked all units
    if @unit_index == @player_turn.units.size
      # Stop income sound effect if it is playing
      if @playing_income_se
        @playing_income_se = false
        Audio.bgs_stop
        Config.play_se("income_end")
      end
      # Go to last phase
      @preturn = 5
      @unit_index = 0
    end
  end
  #--------------------------------------------------------------------------
  # Preturn 5 : Finish
  #   Enables player control and resets variables for the next player.
  #--------------------------------------------------------------------------
  def preturn_finish
    cursor.add_move_action(@player_turn.x, @player_turn.y, nil, 30)
    cursor.move_speed = 5
    @phase = 1
    @preturn = 1
    cursor.disable_input = false
  end

  #-----------------------------------------------------------------------------
  # Phase 1 => Cursor
  #   Controls all related functions of cursor control. Process everything that
  #   isn't part of unit commands (this includes menus/windows)
  #-----------------------------------------------------------------------------
  def phase_cursor
    # Process the below unless the cursor is currently moving
    unless cursor.moving?
      # Get unit at cursor's location
      selected_unit = $game_map.get_unit(cursor.x, cursor.y, false)
      # At first instance of "A Button" and attack ranges aren't being shown
      if Input.trigger?(Input::C) and !Input.press?(Input::B) and @ranges == []
        # Get the tile located at the cursor
        tile = $game_map.get_tile(cursor.x, cursor.y)
        # If unit exists and has not acted and not doing anything else
        if !selected_unit.nil? and !selected_unit.acted
          $game_system.se_play($data_system.decision_se)
          @selected_unit = selected_unit
          @show_move = true
          # If tile can build units and it belongs to you, draw build units window
        elsif tile.is_a?(Property) and tile.build_list(@player_turn) != false and tile.army == @player_turn and selected_unit.nil?
          Config.play_se("decide")
          #Draw build command
          units = tile.build_list(@player_turn)
          @build_window = Build_Window.new(units)
          @build_window.z = 10000
          @phase = 6
        else
          Config.play_se("decide")
          @open_menu = true
        end
        # At first instance of "B Button"
      elsif Input.trigger?(Input::B)
        # If unit exists, show attack range
        if !selected_unit.nil?
          @show_ranges = true
          @selected_unit = selected_unit
          # Else unit doesn't exist, start screen scrolling
        elsif $game_map.get_tile(cursor.x,cursor.y).is_a?(Minicannon) or
        $game_map.get_tile(cursor.x,cursor.y).is_a?(BlackCannon) or
        $game_map.get_tile(cursor.x,cursor.y).is_a?(LaserCannon)
          @show_ranges = true
        else
          cursor.move_speed = 8
        end
      elsif $DEBUG #--------------------------------------------------------
        if Input.trigger?(Input::Key['Shift'])
          p "Day " + $game_map.day.to_s
        elsif Input.repeat?(Input::Key['F'])
          selected_unit.fuel -= 5 unless selected_unit.nil?
        elsif Input.trigger?(Input::Key['P'])
          @player_turn.stored_energy += 100
        elsif Input.trigger?(Input::Key['H'])
          selected_unit.injure(10,false,false) unless selected_unit.nil?
        elsif Input.trigger?(Input::Key['L'])
          $thing = SecondScreen.new
          #$thing = UnitList_Window.new(@player_turn.units)
        end        #--------------------------------------------------------
      end
    end
    # If the "B Button" is released
    if !Input.press?(Input::B)
      # If attack ranges are being displayed
      if @show_ranges
        @show_ranges = false
        @selected_unit.selected = false unless @selected_unit.nil?
        @selected_unit = nil
        # If screen scrolling is currently in progress
      elsif cursor.speed_up
        cursor.move_speed = 5
      end
    end
    
    # TESTING==================================================
    # If player wants to see attack range of unit (first instance)
    if @show_ranges and @ranges == []
      if @selected_unit.nil?
        $game_system.se_play($data_system.decision_se)
        @positions = $game_map.get_tile(cursor.x,cursor.y).attack_range
        draw_ranges(@positions, 2)
      elsif @selected_unit.ammo > 0 or @selected_unit.secondary
        # Needed to turn off some flag graphics on the unit
        @selected_unit.selected = true
        # Draw attack range
        $game_system.se_play($data_system.decision_se)
        @positions = calc_pos(@selected_unit, "attack")
        draw_ranges(@positions, 2) #creates @ranges array
      else
        # Play a buzzer sound to indicate no weapons. Trigger needed to prevent repeated buzzing.
        $game_system.se_play($data_system.buzzer_se) if Input.trigger?(Input::B)
      end
      # If player cancels seeing the attack range, dispose the tiles
    elsif !@show_ranges and @ranges != []
  #    @ranges.each{|tile| tile.dispose}
      
      #TESTING
      @ranges.each{|tile| tile.visible = false}
      
      
      @ranges = []
      #=============================================================
    end
    # If move range should be shown
    if @show_move and @ranges == []
      @phase = 2
      # Remove flag graphics on the unit
      @selected_unit.selected = true
      @positions = calc_pos(@selected_unit, "move")
      draw_ranges(@positions, 1) #creates @ranges array
    end
    # Player opens menu. Could probably be moved up more.
    if @open_menu
      @phase = 6
      commands = []
      commands.push("Cancel")
      commands.push("CO")
      commands.push("Power") if @player_turn.can_use_power? and !@player_turn.using_power?
      commands.push("Super Power") if @player_turn.can_use_super?
      commands.push("End Turn")
      @menu = Window_Command.new(200, commands, true)
      @menu.z = 10000
      @menu.set_at(220, 100)
    end
    # Update @ranges
    @ranges.each{|i| i.update}
    
    @minimap.update unless @minimap.nil?
  end
  #-----------------------------------------------------------------------------
  # Phase 2 => Command
  #   Called when a unit is selected to carry out orders. Called when pressing
  #   'C' on own units or enemies (movement range).
  #-----------------------------------------------------------------------------
  def phase_command
    # Process commands only if the player isn't moving
    ####################### EDIT FOR MOVING CURSOR
    # Pressing B during the movement phase of a unit causes error
    unless cursor.moving?
      # Cancel move command
      if Input.trigger?(Input::B) and !@selected_unit.nil?
        $game_system.se_play($data_system.cancel_se)
        @show_move = false
        @selected_unit.selected = false
        @selected_unit = nil
      end
    end
    
    # Draw any arrows for route drawing
    if @show_move
      # Everytime the player moves, the route is redrawn
      if cursor_moved?
        update_player_route
        # If player is pressing C (confirm)
      elsif Input.trigger?(Input::C)
        # If location of confirmation is at a possible spot and this is player's unit
#kk20        if @positions.include?([cursor.x, cursor.y]) and @selected_unit.army == @player_turn
        if @positions[cursor.x][cursor.y].is_a?(MoveTile) and @selected_unit.army == @player_turn
          # Remember the [x,y] for unit command purposes
          @decided_spot_x = cursor.x
          @decided_spot_y = cursor.y
          commands = determine_unit_commands(@selected_unit)
          # If commands exist
          if commands != []
            width = 0
            temp_bitmap = Bitmap.new(32, 32)
            commands.each{|c|
              size = temp_bitmap.text_size(c).width
              width = size if size > width
            }
            # Draw unit command window
            @unit_command_window = Unit_Command_Window.new(width + 50, commands, true, @selected_unit)
            @phase = 6
          end
          # If location of confirmation is at an impossible spot
        else
          $game_system.se_play($data_system.buzzer_se)
        end
      end
      # If player pressed "B" to cancel order to move or if unit already moved
    else
      @phase = 1
#      @ranges.each{|tile| tile.dispose}
      
      
      #TESTING
      @ranges.each{|tile| tile.visible = false}
      
      @ranges = []
      @arrow_path.each{|a| a.dispose}
      @arrow_path = []
      @path_cost = 0
      @passed_positions = []
      @per_cost = []
    end
    # Update @ranges
    @ranges.each{|i| i.update}
    # Update arrow path
    @arrow_path.each{|i| i.update}
  end
  
  #-----------------------------------------------------------------------------
  # Phase 3 => Action
  #   Carries out the order based on action.
  #-----------------------------------------------------------------------------
  def phase_action
    # carry out the command after done moving (if it is not Wait)
    if !@action.nil? and !$spriteset.unit_moving
      @store_cursor_loc = nil
      cursor.move_speed = 5
      # If the unit was ambushed along its path
      unless @selected_unit.trap
        case @action
        when "Capt"
          building = $game_map.get_tile(cursor.x, cursor.y)
          @selected_unit.capture(building)
        when "Launch"
          # Launch the silo
          silo = $game_map.get_tile(@selected_unit.x, @selected_unit.y)
          silo.launch
          # Gets all spaces within 2 tiles at this x,y spot
          blast_radius = $game_map.get_spaces_in_area(cursor.x, cursor.y, 2)
          blast_radius.each{|loc|
            unit = $game_map.get_unit(loc[0], loc[1])
            next if unit.nil?
            # Damage the unit by 3HP, but don't kill it
            unit.injure(30, false, false)
          }
          $game_screen.start_shake(8, 10, 20)
          cursor.animation_id = 109
        when "Join"
          @selected_unit.join(@unit_to_join_with)
        when "Supply"
          units_nearby = $game_map.get_nearby_units(@selected_unit.x, @selected_unit.y)
          units_nearby.each{|u|
            # If the space is empty
            next unless u.is_a?(Unit)
            # If the unit is of the same army and has low supplies
            if u.army == @selected_unit.army and (u.fuel < u.max_fuel or u.ammo < u.max_ammo)
              u.supply
            end
          }
        when "Dive","Hide","Surface","Appear"
          @selected_unit.hiding = (!@selected_unit.hiding)
        when "Load"
          @carrying_unit.load(@selected_unit)
          Config.play_se("load")
          # REQUIRES EDIT FOR INSTANCES OF HIDDEN UNITS BEING ON THE DROP SPOT
        when "Drop", "Drop ", "Wait "
          # Dropping two units
          if @second_drop_unit != nil
            # Determine direction to drop units based on player's input
            if @action == "Drop"
              second_unit_dir = @drop_dir_1
              first_unit_dir = @drop_dir_2
            else
              second_unit_dir = @drop_dir_2
              first_unit_dir = @drop_dir_1
            end
            # Empty the holding array
            @selected_unit.holding_units = []
            # Place the dropping units at the carrier's (x,y)
            @first_drop_unit.x = @selected_unit.x
            @first_drop_unit.y = @selected_unit.y
            @second_drop_unit.x = @selected_unit.x
            @second_drop_unit.y = @selected_unit.y
            # Call the spriteset to draw these units
            $spriteset.draw_unit(@first_drop_unit)
            $spriteset.draw_unit(@second_drop_unit)
            # Check if there is a hidden unit at the drop sites
            hidden1 = case first_unit_dir[0]
            when 2 then $game_map.get_unit(@first_drop_unit.x, @first_drop_unit.y+1)
            when 4 then $game_map.get_unit(@first_drop_unit.x-1, @first_drop_unit.y)
            when 6 then $game_map.get_unit(@first_drop_unit.x+1, @first_drop_unit.y)
            when 8 then $game_map.get_unit(@first_drop_unit.x, @first_drop_unit.y-1)
            end
            hidden2 = case second_unit_dir[0]
            when 2 then $game_map.get_unit(@second_drop_unit.x, @second_drop_unit.y+1)
            when 4 then $game_map.get_unit(@second_drop_unit.x-1, @second_drop_unit.y)
            when 6 then $game_map.get_unit(@second_drop_unit.x+1, @second_drop_unit.y)
            when 8 then $game_map.get_unit(@second_drop_unit.x, @second_drop_unit.y-1)
            end
            # If the dropped units encountered a hidden unit, load back in carrier
            # Otherwise, move the unit normally
            unless hidden1.nil?
              hidden1.sprite.play_animation('trap')
              @selected_unit.load(@first_drop_unit)
            else
              Config.play_se('drop')
              @first_drop_unit.sprite.move(first_unit_dir)
            end
            unless hidden2.nil?
              hidden2.sprite.play_animation('trap')
              @selected_unit.load(@second_drop_unit)
            else
              Config.play_se('drop')
              @second_drop_unit.sprite.move(second_unit_dir)
            end
            
            # Dropping one unit
          else
            first_unit_dir = (@drop_dir_1 != nil ? @drop_dir_1 : @drop_dir_2)
            @selected_unit.holding_units.delete(@first_drop_unit)
            @first_drop_unit.x = @selected_unit.x
            @first_drop_unit.y = @selected_unit.y
            $spriteset.draw_unit(@first_drop_unit)
            hidden1 = case first_unit_dir[0]
            when 2 then $game_map.get_unit(@first_drop_unit.x, @first_drop_unit.y+1)
            when 4 then $game_map.get_unit(@first_drop_unit.x-1, @first_drop_unit.y)
            when 6 then $game_map.get_unit(@first_drop_unit.x+1, @first_drop_unit.y)
            when 8 then $game_map.get_unit(@first_drop_unit.x, @first_drop_unit.y-1)
            end
            unless hidden1.nil?
              hidden1.sprite.play_animation('trap')
              @selected_unit.load(@first_drop_unit)
            else
              Config.play_se(@first_drop_unit.move_se)
              @first_drop_unit.sprite.move(first_unit_dir)
            end
          end
        when "Fire"
          damage_result = @selected_unit.fire(DMG_RESULT, @target_unit)
          # Charge power bars
          if @target_unit.is_a?(Unit)
            @target_unit.army.charge_power(@target_unit, damage_result[0], 100)
            @player_turn.charge_power(@target_unit, damage_result[0], 50)
          end
          # Deal damage
          @target_unit.injure(damage_result[0], false, true)
          @selected_unit.injure(damage_result[1], false, true)
        end
      end
      # Reset values
      @selected_unit.trap = false
      @first_drop_unit = nil
      @second_drop_unit = nil
      @drop_dir_1 = nil
      @drop_dir_2 = nil
      @first_drop_spot = []
      @target_unit = nil
      @action = nil
      @selected_unit.selected = false
      # Move cursor to this new spot
      #cursor.moveto(@selected_unit.x, @selected_unit.y, true)
      @selected_unit = nil
      # End of action phase, work its way back to phase 1
      @phase = 2
      cursor.disable_input = false
      $spriteset.update_fow
    end
  end
  
  #-----------------------------------------------------------------------------
  # Phase 4 => Decision
  #   Called when the player needs to specify a target/location for an action.
  #   This applies to dropping units, attacking, and launching silos.
  #-----------------------------------------------------------------------------
  def phase_decision
    unless cursor.moving?
      if Input.trigger?(Input::C)
        @confirm_choice = true
      elsif Input.trigger?(Input::B)
        @cancel_choice = true
        $game_system.se_play($data_system.cancel_se)
      end
    end
    Config.play_se("target") if (@action == "Fire" and @zones[cursor.x, cursor.y].is_a?(MoveTile) and Input.dir4 != 0)
    # Update arrow path
    @arrow_path.each{|i| i.update}
    # Update @zones tiles
    @locations.each{|tile| tile.update}
    # If player pressed "C"
    if @confirm_choice
      @confirm_choice = false
      # If launching a missile silo
      if @action == "Launch"
        cursor.character_name = "cursor"
        # Remove the unit command window
        @unit_command_window.dispose
        @unit_command_window = nil
        # Prepare unit for moving
        process_movement
        # Reset values
  #      @locations.each{|tile| tile.dispose}
        
        #TESTING
        @locations.each{|tile| tile.visible = false}
        
        @locations = []
        @zones = []
      elsif @zones[cursor.x][cursor.y].is_a?(MoveTile)#.include?([cursor.x, cursor.y])   kk20
        # If the action is to attack a unit or structure
        if @action == "Fire"
          @target_unit = $game_map.get_unit(cursor.x, cursor.y)
          if @target_unit.nil?
            @target_unit = $game_map.get_tile(cursor.x, cursor.y)
          end
          # The action is to drop a unit
        else
          if @action == "Drop"
            if @decided_spot_x - cursor.x == 1 #left
              @drop_dir_1 = [4]
            elsif @decided_spot_x - cursor.x == -1 #right
              @drop_dir_1 = [6]
            elsif @decided_spot_y - cursor.y == 1 #up
              @drop_dir_1 = [8]
            elsif @decided_spot_y - cursor.y == -1 #down
              @drop_dir_1 = [2]
            end
          elsif @action == "Drop "
            if @decided_spot_x - cursor.x == 1 #left
              @drop_dir_2 = [4]
            elsif @decided_spot_x - cursor.x == -1 #right
              @drop_dir_2 = [6]
            elsif @decided_spot_y - cursor.y == 1 #up
              @drop_dir_2 = [8]
            elsif @decided_spot_y - cursor.y == -1 #down
              @drop_dir_2 = [2]
            end
          end
          # Is this the first unit being dropped? Or the second?
          if @first_drop_unit.nil?
            if @action == "Drop"
              @first_drop_unit = @selected_unit.holding_units[0]
            else
              @first_drop_unit = @selected_unit.holding_units[1]
            end
          else
            if @action == "Drop"
              @second_drop_unit = @selected_unit.holding_units[0]
            else
              @second_drop_unit = @selected_unit.holding_units[1]
            end
          end
          # For the next conditional line
          if @action == "Drop"
            direction = @drop_dir_1
          else
            direction = @drop_dir_2
          end
          # If there is still another unit that can be dropped and there is
          # space for it to be dropped.
          if @unit_command_window.two_drop_commands and @second_drop_unit.nil? and can_drop_second?(@selected_unit, direction)
            Config.play_se("decide")
            @unit_command_window.new_commands
            @phase = 6
            @unit_command_window.index = 0
            @unit_command_window.visible = true
      #      @locations.each{|tile| tile.dispose}
            
            
            #TESTING
            @locations.each{|tile| tile.visible = false}
            
            @locations = []
            @zones = []
            return
          end
        end
        # Remove the unit command window
        @unit_command_window.dispose
        @unit_command_window = nil
        # Prepare unit for moving
        process_movement
        # Reset values
    #    @locations.each{|tile| tile.dispose}
        
        
        #TESTING
        @locations.each{|tile| tile.visible = false}
        
        @locations = []
        @zones = []
      else
        $game_system.se_play($data_system.buzzer_se)
      end
    end
    # If player pressed "B"
    if @cancel_choice
      cursor.character_name = "cursor"
      @cancel_choice = false
      # Dispose the zones
  #    @locations.each{|tile| tile.dispose}
      
      #TESTING
      @locations.each{|tile| tile.visible = false}
      
      @locations = []
      @zones = []
      # Return the cursor to the spot where the unit was decided to move to
      cursor.moveto(@decided_spot_x, @decided_spot_y)
      # Show unit command window and move range again. Action is now nil.
      x = (cursor.real_x - $game_map.display_x) / 4
      x -= (@unit_command_window.width/2 - 16)
      y = (cursor.real_y - $game_map.display_y) / 4
      @unit_command_window.set_at(x, y)
      @unit_command_window.visible = true
      # Update @ranges
      @ranges.each{|i| i.update}
      show_move_ranges if @first_drop_unit.nil?
      # Update arrow path
      @arrow_path.each{|i| i.update}
      @action = nil
      # Back to phase 6
      @phase = 6
    end
  end
  
  #-----------------------------------------------------------------------------
  # Phase 5 => Animation
  #   Called if game animations are on. Processes all the animations that take
  #   place in battle (damage scene, capture, powers, etc).
  #-----------------------------------------------------------------------------
  def phase_animation
    
  end
  #-----------------------------------------------------------------------------
  # Phase 6 => Menu
  #   Process menu commands.
  #-----------------------------------------------------------------------------
  def phase_menu
    #////////////////////////////////////////////
    # Menu Window Commands
    #////////////////////////////////////////////
    if !@menu.nil? and @menu.visible
      @menu.update
      if Input.trigger?(Input::C)
        case @menu.at_index
        when "Cancel"
          $game_system.se_play($data_system.cancel_se)
          @menu.dispose
          @menu = nil
          @phase = 1
          @open_menu = false
        when "CO"
          Config.play_se("decide")
          @officer_window = OfficerBio_Window.new(@player_turn.officer)
          @officer_window.z = 99999
          @menu.visible = false
        when "End Turn"
          Audio.bgm_fade(5000)
          Config.play_se("decide")
          @player_turn.set_cursor(cursor.x, cursor.y)
          cursor.move_speed = 8.00001
          @menu.dispose
          @menu = nil
          @phase = 7
          @open_menu = false
        when "Power"
          if @player_turn.officer.nation == "Black Hole"
            $game_system.bgm_play("BHPower")
          else
            $game_system.bgm_play("Power")
          end
          @player_turn.use_power
          @menu.dispose
          @menu = nil
          @phase = 1
          @open_menu = false
        when "Super Power"
          if @player_turn.officer.nation == "Black Hole"
            $game_system.bgm_play("BHSuperPower")
          else
            $game_system.bgm_play("SuperPower")
          end
          @player_turn.use_power(true)
          @menu.dispose
          @menu = nil
          @phase = 1
          @open_menu = false
        end
      elsif Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @menu.dispose
        @menu = nil
        @phase = 1
        @open_menu = false
      end
      #////////////////////////////////////////////
      # Build Window Commands
      #////////////////////////////////////////////
    elsif !@build_window.nil?
      
      if Input.trigger?(Input::C)
        if @player_turn.funds >= @build_window.unit.cost
          Config.play_se("decide")
          @build_window.build_unit
          @build_window.dispose
          @build_window = nil
          @phase = 1
          $spriteset.update_fow
        else
          $game_system.se_play($data_system.buzzer_se)
        end
      elsif @build_window.active and Input.trigger?(Input::B) 
        $game_system.se_play($data_system.cancel_se)
        @build_window.dispose
        @build_window = nil
        @phase = 1
      end
      @build_window.update unless @build_window.nil?
      #////////////////////////////////////////////
      # Unit Commands Window
      #////////////////////////////////////////////
    elsif !@unit_command_window.nil?
      @unit_command_window.update
      if Input.trigger?(Input::C)
        # determine choice
        @action = @unit_command_window.command
        # If the player chose Can't Fire, play buzzer
        if @action == "Fire "
          @action = nil
          $game_system.se_play($data_system.buzzer_se)
        else
          # If the action chosen is the following, call phase 4.
          # These actions need the player's direction on what to target.
          if ["Fire","Drop","Drop ","Launch"].include?(@action)
            Config.play_se("decide")
            show_move_ranges(false)
            if @action == "Fire"
              # If direct combat unit
              if @selected_unit.max_range == 1
                @zones = calc_pos(@selected_unit, "direct", cursor.x, cursor.y)
                remove_empty_zones(1, @selected_unit)
                # If indirect combat unit
              else
                @zones = calc_pos(@selected_unit, "attack")
                remove_empty_zones(1, @selected_unit)
              end
              draw_ranges(@zones, 3)
            elsif @action == "Drop" or @action == "Drop "
              @zones = calc_pos(@selected_unit, "direct", cursor.x, cursor.y)
              remove_empty_zones(0, @selected_unit)
              draw_ranges(@zones, 4)
            elsif @action = "Launch"
              cursor.character_name = "silocursor"
            end
            @unit_command_window.visible = false
            @phase = 4
          else
            # dispose window
            @unit_command_window.dispose
            @unit_command_window = nil
            # begin the movement of the unit
            process_movement
          end
        end
        # If cancel to make a command
      elsif Input.trigger?(Input::B)
        # Reset drop values (even if the unit can't drop anything)
        @first_drop_unit = nil
        @second_drop_unit = nil
        @drop_dir_1 = nil
        @drop_dir_2 = nil
        @first_drop_spot = []
        # Return to phase 2 (unit movement select)
        $game_system.se_play($data_system.cancel_se)
        @unit_command_window.dispose
        @unit_command_window = nil
        show_move_ranges
        @phase = 2
      end
    #************************
    # Officer Bio Window
    #************************
    elsif !@officer_window.nil?
      @officer_window.update
      if @officer_window.delete
        @officer_window = nil
        @menu.visible = true
      end
    end
    
  end
  #-----------------------------------------------------------------------------
  # Phase 7 => Endturn
  #   Called when player ends their turn. Resets values and sets new conditions.
  #-----------------------------------------------------------------------------
  def phase_endturn
    cursor.disable_input = true
    # Set next player. Advance day if first player's turn.
    next_player = @player_turn.id
    while $game_map.army[next_player].nil?
      next_player = (next_player + 1) % 4
      $game_map.day += 1 if next_player == 0
    end
    @player_turn = $game_map.army[next_player]
    # Update FOW
    $spriteset.update_fow
    # Update all the units' status effects
    $game_map.units.each{|u| u.update_status_effects}
    # Revert unit colors, putting in some delays 
    proc = Proc.new{$spriteset.revert_unit_colors}
    cursor.add_move_action(cursor.x, cursor.y, nil, 10, proc)
    cursor.add_move_action(cursor.x, cursor.y, nil, 30)
    # Move cursor to next player's last location
    cursor.add_move_action(@player_turn.x, @player_turn.y, nil, 30)
    #
    $spriteset.draw_officer_tag
    @phase = 0
  end
end
