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
 - 11/28/14
   + Multi-day process of overhauling the class. Removed a ton of variables and
     replaced them with new, more meaningful ones. 
   + FOW methods removed
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
class Scene_AWMap
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    #DEBUG
    $thing.update unless $thing.nil?
    
    # Update the map and frame count
    $game_map.update
    # Update any running events
    $game_system.map_interpreter.update
    # Update the player
    cursor.update 
    # Update system (timer), screen shakes/tints
    $game_system.update
    $game_screen.update
    # Update sprite set (updates all the graphics on screen like unit or cursor)
    $spriteset.update
    # Update arrow path
    @arrow_path.each{|i| i.update}
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
  end
  #--------------------------------------------------------------------------
  # Moves the cursor to a specified location to perform an action created by
  # a Proc object.
  #--------------------------------------------------------------------------
  def process_cursor_movement_commands
    # If there is a cursor action
    if cursor.moveto_locations[0] != nil
      # Disable cursor and speed it up
      cursor.disable_input = true
      cursor.scroll_mode = 2
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
          # Call the Proc object if it exists
          @proc[0].call unless @proc[0].nil?
          # Check for how long to wait
          case @proc[1]
          # If waiting for the Power animation of the cursor or unit to finish
          when WAIT_CURSOR_POWER, WAIT_UNIT_POWER 
            # If there is another cursor action remaining AND it has the same
            # wait value as this current cursor action
            if cursor.moveto_actions[0] != nil && cursor.moveto_actions[0][1] == @proc[1]
              # Create a slight frame delay before moving onto the next command
              @wait = 12
            else
              # Wait for the power animation to finish playing before continuing
              @wait = -2
            end
          else
            # Just assign the wait value of the cursor action
            @wait = @proc[1]
          end
        end
      end
    # Cursor is at its location  
    else
      # Unit is being repaired, deduct funds per frame
      if @making_repairs
        # If wait is 0, it will finalize the deduction, fixing any rounding errors
        @player.frame_repair(@wait == 0) 
      end
      # Do not progress any further until the wait counter is over or animation
      # has finished playing
      return if @wait > 0
      if @wait == -2
        return unless $spriteset.animation_end?
      end
      # Reset wait value
      @wait = 0
      # Call the end Proc object, if any
      @proc[2].call if @proc[2] != nil
      # Move on to the next cursor action
      cursor.moveto_locations.shift
      # If no more actions, allow player input again (unless the last action disallows it)
      if cursor.moveto_locations.size == 0 && !@proc[3]
        cursor.disable_input = false
        cursor.scroll_mode = false
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
      if $game_map.army.compact.size > 2
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
            loser_army.owned_props[0].army = @player
          end
        end
        # Set this army to nil so it will no longer be evaluated
        $game_map.army[loser_army.id-1] = nil
        # If lost on own turn, then advance to next player's turn
        @phase = 7 if loser_army == @player
      else
        winner_army = $game_map.army.compact[0]
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
    when 3 then phase_decision
    when 4 then phase_action
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
    @player.units.each{|u|
      if u.disabled
        u.acted = true
        u.disabled = false
      end
    }
    # Play the player's CO theme music
    $game_system.bgm_play(@player.officer.name)
    # Turn off COP and SCOP flags
    @player.officer.cop = false
    @player.officer.scop = false
    # Play sound effect if the player's COP/SCOP is full
    if @player.stored_energy == @player.officer.scop_rate
      Config.play_se("superpower")
    elsif @player.stored_energy >= @player.officer.cop_rate and @player.officer.cop_stars != 0
      Config.play_se("power")
    end
    # If there is a weather effect
    if $game_map.current_weather != 'none'
      # Check if need to turn off the current weather
      if $game_map.turn_weather_off(@player)
        $game_map.set_weather('none')
      end
    end
    # Draw the player's officer tag graphic located at the top of the screen (EDIT the way graphic is drawn)
    $spriteset.draw_officer_tag(@player)
    # Adds funds based on properties owned that give income
    @player.earn_daily_income
    # If the player has any units out or if it's day one (EDIT)
    unless @player.units.size == 0
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
      if @unit_index >= @player.units.size
        @unit_index = 0
        @preturn = 3
        return
      end
      # Depletes daily fuel costs
      unit = @player.units[@unit_index]
      tile = $game_map.get_tile(unit.x, unit.y)
      # If the unit is NOT over a property that can supply this unit, burn fuel
      unit.daily_fuel if !tile.can_repair(unit) 
      @unit_index += 1
      
      if unit.needs_deletion
        @wait = -1
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
    if @unit_index == @player.units.size
      @preturn = 4
      @unit_index = 0
      return
    end
    # Loop until found a unit to repair
    loop do
      # If no more units, move onto next phase
      if @unit_index == @player.units.size
        @preturn = 4
        @unit_index = 0
        break
      end
      # Holds list of commands size to check if new commands will be added later
      listsize = cursor.moveto_locations.size
      
      unit = @player.units[@unit_index]
      # Advance to next unit in list
      @unit_index += 1
      # Apply daily unit updates
      unit.made_repairs = false
      # Check if the unit is even on the map
      next if $game_map.get_unit(unit.x, unit.y) != unit
      # Check if unit can be healed
      tile = $game_map.get_tile(unit.x, unit.y)
      # If unit is damaged, not loaded and on a tile that can repair it
      if tile.can_repair(unit) 
        if unit.health < 100 and !unit.loaded 
          Config.play_se("income") unless @playing_income_se
          @playing_income_se = true
          # Move cursor to unit's spot and play repair animation
          proc = Proc.new{unit.sprite.play_animation('repair'); unit.supply}
          wait_time = @player.daily_repair(unit, tile)
          endproc = Proc.new{unit.repair(@player.repair_amount)
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
      unit = @player.units[@unit_index]
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
            endproc = Proc.new{u.sprite.stop_loop_animation}
            cursor.add_move_action(u.x, u.y, proc, 30, endproc)
          end
        }
        break
      end
      break if @unit_index == @player.units.size
    end
    # If checked all units
    if @unit_index == @player.units.size
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
    cursor.add_move_action(@player.x, @player.y, nil, 30)
    cursor.scroll_mode = false
    @phase = 1
    @preturn = 1
    cursor.disable_input = false
    #cursor.visible = true
  end

  #-----------------------------------------------------------------------------
  # Phase 1 => Cursor
  #   Controls all related functions of cursor control. Process everything that
  #   isn't part of unit commands (this includes menus/windows)
  #-----------------------------------------------------------------------------
  def phase_cursor
    # The cursor is always active in this phase
    cursor.disable_input = false
    # Process the below unless the cursor is currently moving
    unless cursor.moving?
      # If scroll mode is activated
      if cursor.scroll_mode == 1
        # If the player is no longer holding B, turn off scroll mode
        cursor.scroll_mode = false if !Input.press?(Input::B)
      else # Scroll mode is off
        # Get unit and tile at cursor's location
        unit = $game_map.get_unit(cursor.x, cursor.y, false)
        tile = $game_map.get_tile(cursor.x, cursor.y)
        # At first instance of "A Button" 
        if Input.trigger?(Input::C)
          # If unit exists and has not acted
          if !unit.nil? and !unit.acted
            $game_system.se_play($data_system.decision_se)
            @range_type = 1
            @unit = unit
            @phase = 2
            # Remove flag graphics on the unit
            @unit.selected = true
         #   t=Time.now
            @positions = calc_pos(@unit, "move")
         #   puts Time.now - t
            draw_ranges(@positions, 1) 
          # If tile can build units and it belongs to you, draw build units window
          elsif tile.is_a?(Property) and tile.army == @player and 
          tile.build_list and unit.nil?
            Config.play_se("decide")
            #Draw build command
            units = tile.build_list
            @active_window = Build_Window.new(units, @player)
            @phase = 6
          else
            Config.play_se("decide")
            @phase = 6
            @active_window = MapMenu_Window.new(@player)
          end
          # At first instance of "B Button"
        elsif Input.trigger?(Input::B)
          # If unit exists, show attack range
          if !unit.nil?
            # If unit can attack
            if unit.ammo > 0 or unit.secondary
              @phase = 2
              @range_type = 2
              @unit = unit
              # Needed to turn off some flag graphics on the unit
              @unit.selected = true
              # Draw attack range
              $game_system.se_play($data_system.decision_se)
          #    t=Time.now
              @positions = calc_pos(@unit, "attack")
          #    puts Time.now-t
              draw_ranges(@positions, 2) 
            else
              $game_system.se_play($data_system.buzzer_se)
            end
          # If structure tile with an attack range (i.e. Black Cannon)
          elsif tile.is_a?(Structure) and tile.attack_range
            @phase = 2
            @range_type = 2
            $game_system.se_play($data_system.decision_se)
            @positions = tile.attack_range
            draw_ranges(@positions, 2)
          else # Else unit doesn't exist, start screen scrolling
            cursor.scroll_mode = 1
          end
        elsif $DEBUG #--------------------------------------------------------
          if Input.trigger?(Input::Key['Shift'])
            Transition.new
          elsif Input.repeat?(Input::Key['F'])
            unit.fuel -= 5 unless unit.nil?
          elsif Input.trigger?(Input::Key['P'])
            @player.stored_energy += 100
          elsif Input.trigger?(Input::Key['H'])
            unit.injure(10,false,false) unless unit.nil?
          elsif Input.trigger?(Input::Key['I'])
            @infmap.generate_map
          elsif Input.trigger?(Input::Key['U'])
            @infmap.draw_infl
          elsif Input.trigger?(Input::Key['B'])
            @infmap.determine_best_move(0)
          elsif Input.trigger?(Input::Key['O'])
            puts @infmap.map[cursor.x, cursor.y].unit_infl
            puts @infmap.map[cursor.x, cursor.y].prop_infl
            puts @infmap.map[cursor.x, cursor.y].inf_value[0] - @infmap.map[cursor.x, cursor.y].inf_value[1]
            puts '===================================='
          elsif Input.trigger?(Input::Key['L'])
            $thing = SecondScreen.new
          elsif Input.trigger?(Input::Key['0'])
            @unit = unit
            @command = Unit_Command.new
            @passed_positions = [4, 4, 2]
            @command.action = "Load"
            @command.target = [2,3]
            process_movement
            #$thing = UnitList_Window.new(@player.units)
          elsif Input.trigger?(Input::Key['R'])
            puts @infmap.map[cursor.x, cursor.y].regionid
          
          end        #--------------------------------------------------------
        end
      end
    end

    
    @minimap.update unless @minimap.nil?
  end
  #-----------------------------------------------------------------------------
  # Phase 2 => Command
  #   Called when a unit is selected to carry out orders. Called when pressing
  #   'C' on own units or enemies (movement range).
  #-----------------------------------------------------------------------------
  def phase_command
    # Determine action based on what ranges are currently being viewed
    case @range_type
    when 1 # Move
      # Update drawing the arrow path
      update_player_route if cursor.moved?
      # Do not process input if the cursor is still moving
      unless cursor.moving?
        if Input.trigger?(Input::C)
          # If unit belongs to the player and within unit's move range
          if @unit.army == @player and !@positions[cursor.x][cursor.y].nil?
            # Setup a new command
            @command = Unit_Command.new
            # Store location for command
            @command.move = [cursor.x, cursor.y]
            commands = determine_unit_commands
            # If commands exist
            if commands != []
              Config.play_se("decide")
              width = 0
              temp_bitmap = Bitmap.new(32, 32)
              commands.each{|c|
                size = temp_bitmap.text_size(c).width
                width = size if size > width
              }
              # Draw unit command window
              @active_window = Unit_Command_Window.new(width + 50, commands, true, @unit)
              cursor.disable_input = true
              @phase = 3
            else
              # Invalid spot to move to
              $game_system.se_play($data_system.buzzer_se)
            end
          else # Invalid move, buzzer sound
            $game_system.se_play($data_system.buzzer_se)
          end
        elsif Input.trigger?(Input::B)
          $game_system.se_play($data_system.cancel_se)
          @unit.selected = false
          @unit = nil
          @phase = 1
          remove_ranges
          dispose_arrows
        end
      end

    when 2 # Attack
      if !Input.press?(Input::B)
        @unit.selected = false
        @unit = nil
        @phase = 1
        remove_ranges
      end
      
    end

    
  end
  
  #-----------------------------------------------------------------------------
  # Phase 3 => Decision
  #   Determine what command to give the unit, including choosing targets.
  #-----------------------------------------------------------------------------
  def phase_decision
    
    if @active_window.visible
      cursor.disable_input = true
      @active_window.update
      if Input.trigger?(Input::C)
        # Assign command action
        @command.action = @active_window.command
        case @command.action
        # If the player chose Can't Fire, play buzzer
        when "Fire "
          @command.action = nil
          $game_system.se_play($data_system.buzzer_se)
        when "Fire"
          Config.play_se("decide")
          remove_ranges
          # If direct combat unit
          if @unit.max_range == 1
            @positions2 = calc_pos(@unit, "direct", *@command.move)
            remove_empty_zones(1, @unit)
            # If indirect combat unit
          else
            @positions2 = calc_pos(@unit, "attack")
            remove_empty_zones(1, @unit)
          end
          draw_ranges(@positions2, 3)
          @active_window.visible = false
        when "Drop","Drop "
          Config.play_se("decide")
          remove_ranges
          @positions2 = calc_pos(@unit, "direct", *@command.move)
          remove_empty_zones(0, @unit)
          draw_ranges(@positions2, 4)
          @active_window.visible = false
        when "Launch"
          Config.play_se("decide")
          remove_ranges
          cursor.character_name = "silocursor"
          @active_window.visible = false
        else
          @command.target = [cursor.x, cursor.y]
          # dispose window
          @active_window.dispose
          @active_window = nil
          # begin the movement of the unit
          process_movement
        end
        # If cancel to make a command
      elsif Input.trigger?(Input::B)
        # Reset command target(s)
        @command.target = []
        # Return to phase 2 (unit movement select)
        $game_system.se_play($data_system.cancel_se)
        @active_window.dispose
        @active_window = nil
        @phase = 2
        cursor.disable_input = false
      end
    else # Choosing location
      cursor.disable_input = false
      # Plays the sound effect when selecting a target... needs changing
      Config.play_se("target") if (@command.action == "Fire" and !@positions2[cursor.x, cursor.y].nil? and Input.dir4 != 0)
      # Don't process input if cursor is moving
      unless cursor.moving?
        # If player pressed "C"
        if Input.trigger?(Input::C)
          # If launching a missile silo
          if @command.action == "Launch"
            # Revert cursor graphic
            cursor.character_name = "cursor"
            @command.target = [cursor.x, cursor.y]
          elsif !@positions2[cursor.x][cursor.y].nil?
            
            # If the action is to attack a unit or structure
            if @command.action == "Fire"
              @command.target = [cursor.x, cursor.y]
            # The action is to drop a unit
            else
              if @active_window.command == "Drop "
                @command.action_drop(cursor.x, cursor.y, @unit.holding_units[1])
              elsif @active_window.command == "Drop"
                @command.action_drop(cursor.x, cursor.y, @unit.holding_units[0])
              end
              # If there is still another unit that can be dropped
              drop_list = can_drop_list
              
              
              if drop_list
                # TEMPORARY FIX
                if @active_window.command == "Drop"
                  drop_list.insert(0, nil)
                else
                  drop_list.push(nil)
                end
                
                Config.play_se("decide")
                @active_window.new_commands(drop_list)
                @active_window.index = 0
                @active_window.visible = true
                @positions2 = []
                return
              end
            end
            
          else # Invalid location
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # Remove the unit command window
          @active_window.dispose
          @active_window = nil
          # Prepare unit for moving
          process_movement
          # Reset values
          @positions2 = []
          
        # If player pressed "B"
        elsif Input.trigger?(Input::B)
          cursor.disable_input = true
          $game_system.se_play($data_system.cancel_se)
          cursor.character_name = "cursor"
          # Dispose the zones
          @positions2 = []
          # Return the cursor to the spot where the unit was decided to move to
          cursor.add_move_action(*@command.move)
          # Show unit command window and move range again. Action is now nil.
          @active_window.visible = true
          draw_ranges(@positions, 1)
          @command.action = nil
        end 
      end
    end
    
  end

  #-----------------------------------------------------------------------------
  # Phase 4 => Action
  #   Carries out the command assigned to the unit.
  #-----------------------------------------------------------------------------
  def phase_action
    # carry out the command after done moving (if it is not Wait)
    if !@command.action.nil? and !$spriteset.unit_moving
      # If the unit was ambushed along its path
      unless @unit.trap
        case @command.action
        when "Capt"
          building = $game_map.get_tile(*@command.move)
          @unit.capture(building)
          @unit.acted = true
        when "Launch"
          # Launch the silo
          silo = $game_map.get_tile(*@command.move)
          silo.launch
          # Play missile launch animation
          proc = Proc.new{cursor.animation(112)}
          cursor.add_move_action(*@command.move, proc, WAIT_CURSOR_ANIMATION)
          # Play missile fall animation
          proc = Proc.new{cursor.animation(113)}
          cursor.add_move_action(*@command.target, proc, WAIT_CURSOR_ANIMATION)
          # Play explosion animation and damage units
          proc = Proc.new{  cursor.animation(109)
                            #$game_screen.start_shake(8, 10, 20)
                            blast_radius = $game_map.get_spaces_in_area(cursor.x, cursor.y, 2)
                            blast_radius.each{|loc|
                              unit = $game_map.get_unit(loc[0], loc[1])
                              next if unit.nil?
                              # Damage the unit by 3HP, but don't kill it
                              unit.injure(30, false, false)
                            }
                          }
          cursor.add_move_action(*@command.target, proc, WAIT_CURSOR_ANIMATION)
          # Create delay of 30 frames
          unit = @unit
          cursor.add_move_action(*@command.target, nil, 30, Proc.new{unit.acted = true})
        when "Join"
          @unit.join($game_map.get_unit(*@command.target))
        when "Supply"
          # Start the sound effect loop
          Config.play_se("income")
          units_nearby = $game_map.get_nearby_units(*@command.move)
          units_nearby.each{|u|
            # Skip if the space is empty
            next unless u.is_a?(Unit)
            # If the unit is of the same army and has low supplies
            if u.army == @unit.army and u.need_supplies
              proc = Proc.new{u.sprite.play_animation('supply'); u.supply}
              endproc = Proc.new{u.sprite.stop_loop_animation}
              cursor.add_move_action(u.x, u.y, proc, 30, endproc)
            end
          }
          # Stop the sound effect loop
          unit = @unit
          proc = Proc.new{Audio.bgs_stop
                          Config.play_se("income_end")
                          unit.acted = true}
          cursor.add_move_action(cursor.x, cursor.y, proc, 16)
        when "Dive","Hide","Surface","Appear"
          @unit.hiding = !@unit.hiding
          @unit.acted = true
        when "Load"
          carrier = $game_map.get_unit(*@command.target)
          carrier.load(@unit)
          Config.play_se("load")
        when "Drop", "Drop ", "Wait "
          @command.target.each{|t|
            # Check for a hidden unit at this drop off location
            hidden_unit = $game_map.get_unit(t[0], t[1])
            unless hidden_unit.nil?
              # Play TRAP animation and move on to next unit
              hidden_unit.sprite.play_animation('trap')
              next
            else # Free to drop unit here
              # Play drop off sound effect
              Config.play_se('drop')
              # Draw the unit's sprite
              drop_unit = t[2]
              drop_unit.acted = true
              drop_unit.x, drop_unit.y = @command.move
              drop_unit.init_sprite
              @unit.holding_units.delete(drop_unit)
              
              # Determine move route
              case [@command.move[0] - t[0], @command.move[1] - t[1]]
              when [1, 0] then drop_unit.sprite.move([4]) # left
              when [-1,0] then drop_unit.sprite.move([6]) # right
              when [0, 1] then drop_unit.sprite.move([8]) # up
              when [0,-1] then drop_unit.sprite.move([2]) # down
              end
            end
          }
          # Create pause
          unit = @unit
          cursor.add_move_action(cursor.x, cursor.y, nil, 12, Proc.new{unit.acted = true})
        when "Fire"
          target = $game_map.get_unit(*@command.target)
          target = $game_map.get_tile(*@command.target) if target.nil?
          damage_result = @unit.fire(DMG_RESULT, target)
          # Charge power bars
          if target.is_a?(Unit)
            target.army.charge_power(target, damage_result[0], 100)
            @player.charge_power(target, damage_result[0], 50)
          end
          # Deal damage
          target.injure(damage_result[0], false, true)
          @unit.injure(damage_result[1], false, true)
          @unit.acted = true
        when "Wait"
          @unit.acted = true
        end
      end
      # Reset values
      @unit.trap = false
      @unit.selected = false
      @unit = nil
      @command = nil
      @positions = []
      @positions2 = []
      # Return to phase 1
      @phase = 1
      cursor.disable_input = false
      cursor.scroll_mode = false
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
    cursor.disable_input = true
    # Update the window
    @active_window.update
    #////////////////////////////////////////////
    # Menu Window Commands
    #////////////////////////////////////////////
    if @active_window.is_a?(MapMenu_Window)
      if Input.trigger?(Input::C)
        case @active_window.at_index
        when "Cancel"
          $game_system.se_play($data_system.cancel_se)
          @phase = 1
        when "CO"
          Config.play_se("decide")
          # CHANGE INTO A SCENE OBJECT ****************************************************
          @officer_window = OfficerBio_Window.new(@player.officer)
          @officer_window.z = 99999
        when "Intel"
          return
        when "Options"
          return
        when "End Turn"
          Audio.bgm_fade(5000)
          Config.play_se("decide")
          @player.set_cursor(cursor.x, cursor.y)
          cursor.scroll_mode = 2
          @phase = 7
        when "Power"
          if @player.officer.nation == "Black Hole"
            $game_system.bgm_play("BHPower")
          else
            $game_system.bgm_play("Power")
          end
          @player.use_power
          @phase = 1
        when "Super Power"
          if @player.officer.nation == "Black Hole"
            $game_system.bgm_play("BHSuperPower")
          else
            $game_system.bgm_play("SuperPower")
          end
          @player.use_power(true)
          @phase = 1
        end
        # Delete the window
        dispose_active_window
      elsif Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        dispose_active_window
        @phase = 1
        cursor.disable_input = false
      end
      #////////////////////////////////////////////
      # Build Window Commands
      #////////////////////////////////////////////
    elsif @active_window.is_a?(Build_Window) and @active_window.active
      if Input.trigger?(Input::C)
        if @player.funds >= @active_window.unit.cost(true)
          Config.play_se("decide")
          @active_window.build_unit
          dispose_active_window
          @phase = 1
          cursor.disable_input = false
        else
          $game_system.se_play($data_system.buzzer_se)
        end
      elsif Input.trigger?(Input::B) 
        $game_system.se_play($data_system.cancel_se)
        dispose_active_window
        @phase = 1
        cursor.disable_input = false
      end
    end
    
  end

  #-----------------------------------------------------------------------------
  # Phase 7 => Endturn
  #   Called when player ends their turn. Resets values and sets new conditions.
  #-----------------------------------------------------------------------------
  def phase_endturn
    # This army is no longer playing their turn
    @player.playing = false
    # Set next player. Advance day if first player's turn.
    next_player = @player.id % 4
    while $game_map.army[next_player].nil?
      next_player = (next_player + 1) % 4
      $game_map.day += 1 if next_player == 0
    end
    @player = $game_map.army[next_player]
    @player.playing = true
    # Update all the units' status effects
    $game_map.units.each{|u| u.update_status_effects}
    # Revert unit colors, putting in some delays 
    proc = Proc.new{$spriteset.revert_unit_colors}
    cursor.add_move_action(cursor.x, cursor.y, nil, 10, proc)
    cursor.add_move_action(cursor.x, cursor.y, nil, 30)
    # Move cursor to next player's last location; prevent cursor input afterwards
    cursor.add_move_action(@player.x, @player.y, nil, 30, nil, true)
    #
    $spriteset.draw_officer_tag
    @phase = 0
  end
end
