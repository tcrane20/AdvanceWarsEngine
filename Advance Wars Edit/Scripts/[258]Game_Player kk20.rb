=begin
_______________________
 Game_Character        \________________________________________________________
 
 I think I did this to make certain variables accessible. Made a couple flags
 that indicate if the player is viewing attack or move ranges. Also did
 something regarding looping animations.
 
 Notes:
 * Research what the hell I did
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Game_Character
  attr_accessor :step_anime
  attr_accessor :x, :y
  attr_accessor :character_name
  
  attr_accessor :loop_anim_id # Testing purpose
  alias wars_initialize initialize
  def initialize
    @loop_anim_id = 0
    wars_initialize
  end
end
=begin
_________________________
 Sprite_Character        \______________________________________________________
 
 Looks like I added some kind of looping animation thing here. I think I did
 this for the Supply/Repair animations which are displayed over the cursor. I
 will have to see if this is a smart thing to do or pointless.
 
 The other method looks like sprite displacement. Say for when you are choosing
 a launch zone for a missile silo--the graphic is pretty big. This ensures the
 sprite is placed correctly over the player's x/y location.
 
 Notes:
 * Research my actions
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Sprite_Character < RPG::Sprite
  alias loop_anim_update update
  def update
    loop_anim_update
    if @character.loop_anim_id != 0
      animation = $data_animations[@character.loop_anim_id]
      loop_animation(animation)
      @character.loop_anim_id = 0
    end
  end
  
  alias call_orig_update update
  def update
    call_orig_update
    if @character.is_a?(Game_Player)
      self.y = @character.screen_y + @character.cursor_displacement
    end
  end
end
=begin
____________________
 Game_Player        \___________________________________________________________
 
 Stock RPG Maker class modified for better controls. I basically could call this
 class Cursor < Game_Player and all would be fine. Handles keyboard and mouse
 controls. Probably could be cleaned up good, especially since it makes a LOT
 of references to variables outside of it.
 
 Notes:
 * Should still be able to check if processing an event
 * I think I could clean this up pretty good, and maybe alias a lot of it
 * Should I just make this a different class?
 
 Updates:
 - 11/10/14
   + <slide_to> was reworked. This now needs to be called nearly every frame
     in order for the cursor to get to where it needs to be. Used mainly for
     move-actions; I see no other purpose for this to be used elsewhere.
   + Make sure to remove the slide_to dependencies in other classes. Getting weird
     delays.
 - 11/08/14
   + <add_move_action> was created
 - 11/06/14
  + Movement now has a "repeating" functionality to it
  + Removed all those functions pertaining to moving in a direction and just
    made the sound effect take place in <increase_steps>
________________________________________________________________________________
=end
class Game_Player < Game_Character
  
  attr_accessor :disable_input, :visible
  attr_accessor :moveto_locations, :moveto_actions
  attr_accessor :real_x, :real_y
  attr_reader :scroll_mode
  
  def initialize
    @delay_input = 0
    @repeat_move = false
    @scroll_mode = false
    @moveto_locations = []
    @moveto_actions = []
    @visible = true
    @old_x, @old_y = 0, 0
    
    @move_speed = 5
    @disable_input = false
    super
  end
  
  def increase_steps
    super 
    Config.play_se('cursor') unless @scroll_mode
  end
  
  def animation(id)
    $spriteset.player_sprite.animation($data_animations[id], true)
  end
  
  def moved?
    return self.x != @old_x || self.y != @old_y
  end
  #--------------------------------------------------------------------------
  # * Update method
  #--------------------------------------------------------------------------
  def update
    # Hold last coordinates
    @old_x = self.x
    @old_y = self.y
    
    @step_anime = true
    # If moving, event running, move route forcing, and message window
    # display are all not occurring
    unless moving? or $game_system.map_interpreter.running? or
      @move_route_forcing or $game_temp.message_window_showing or @disable_input
      # Process player controls. If mouse is on game screen, process mouse commands.
      # Otherwise, process keyboard commands.
      # Note that this only applies to moving the cursor.
      mouse_loc = $mouse.position # Get the mouse's location relative to the game screen
      unless mouse_loc == [-1,-1]
        x = (mouse_loc[0] + $game_map.display_x/4) / 32
        y = (mouse_loc[1] + $game_map.display_y/4) / 32
=begin
        scroll_dir = 0
        # If mouse X is too far left
        if mouse_loc[0] < 96
          if $game_map.display_x != 0 || @scroll_mode
            scroll_dir += 1
            x = 3 + $game_map.display_x/128
          end
        end
        # If mouse X is too far right
        if mouse_loc[0] > 543 || @scroll_mode
          if $game_map.display_x != ($game_map.width - 20) * 128
            scroll_dir += 2
            x = 16 + $game_map.display_x/128
          end
        end
        # If mouse Y is too far up
        if mouse_loc[1] < 96 || @scroll_mode
          if $game_map.display_y != 0
            scroll_dir += 4
            y = 3 + $game_map.display_y/128
          end
        end
        # If mouse Y is too far down
        if mouse_loc[1] > 383 || @scroll_mode
          if $game_map.display_y != ($game_map.height - 15) * 128
            scroll_dir += 8
            y = 11 + $game_map.display_y/128
          end
        end
=end
        # Move the cursor to spot
        slide_to(x,y) #moveto(x,y)
=begin
        # If hit the screen borders to allow scrolling
        case scroll_dir
        when 1 # Left
          slide_to(x-1, y)
        when 2 # Right
          slide_to(x+1, y)
        when 4 # Up
          slide_to(x, y-1)
        when 8 # Down
          slide_to(x, y+1)
        when 5 # Up-left
          slide_to(x-1, y-1)
        when 9 # Down-left
          slide_to(x-1, y+1)
        when 6 # Up-right
          slide_to(x+1, y-1)
        when 10# Down-right
          slide_to(x+1, y+1)
        end
=end
      else
        # If not delaying user input
        if @delay_input == 0 && Input.dir8 != 0
          # Move player in the direction the directional button is being pressed
          case Input.dir8
          when 1 then @scroll_mode ? slide_to(3, $game_map.height - 4) : move_lower_left
          when 2 then @scroll_mode ? slide_to(@x, $game_map.height - 4) : move_down
          when 3 then @scroll_mode ? slide_to($game_map.width - 4, $game_map.height - 4) : move_lower_right
          when 4 then @scroll_mode ? slide_to(3, @y) : move_left
          when 6 then @scroll_mode ? slide_to($game_map.width - 4, @y) : move_right
          when 7 then @scroll_mode ? slide_to(3, 3) : move_upper_left
          when 8 then @scroll_mode ? slide_to(@x, 3) : move_up
          when 9 then @scroll_mode ? slide_to($game_map.width - 4, 3) : move_upper_right
          end
          # Apply delay unless scroll mode is activated
          @delay_input = (@repeat_move ? 1 : 12) unless @scroll_mode
        else
          # While the player is holding down a direction, keep fast repeat active
          if Input.dir8 != 0
            @delay_input -= 1
            @repeat_move = true
          else # Turn off the fast repeat
            @delay_input = 0
            @repeat_move = false
          end
        end
        
      end # END of unless mouse is off screen
    end
    
    # Remember coordinates in local variables
    last_real_x = @real_x
    last_real_y = @real_y
    
    super
    
    # If character moves down and is positioned lower than the center
    # of the screen
    if @real_y > last_real_y and (@real_y - $game_map.display_y > 1408)
      # Scroll map down
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # If character moves left and is positioned more let on-screen than
    # center
    if @real_x < last_real_x and (@real_x - $game_map.display_x < 384)
      # Scroll map left
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # If character moves right and is positioned more right on-screen than
    # center
    if @real_x > last_real_x and (@real_x - $game_map.display_x > 2048)
      # Scroll map right
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # If character moves up and is positioned higher than the center
    # of the screen
    if @real_y < last_real_y and (@real_y - $game_map.display_y < 384)
      # Scroll map up
      $game_map.scroll_up(last_real_y - @real_y)
    end
  end
  #--------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen (EDIT)
  # Essentially, if the [x,y] is within the rectangle formed by the screen's
  # current display location minus 3 spaces around the perimeter, then the
  # screen will not move. Otherwise, the screen will move to make the [x,y]
  # located at the center of the screen.
  #--------------------------------------------------------------------------
  def center(x, y)
    screen_x = x * 128
    screen_y = y * 128
    sx = $game_map.display_x + 384
    sy = $game_map.display_y + 384
    if screen_x >= sx and screen_x <= sx + 1664
      # Do nothing
    else
      max_x = ($game_map.width - 20) * 128
      $game_map.display_x = [0, [x * 128 - CENTER_X - 64, max_x].min].max
    end
    if screen_y >= sy and screen_y <= sy + 1024
      # Do nothing
    else
      max_y = ($game_map.height - 15) * 128
      $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
    end
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def moveto(x, y, mouse_jump = false)
    center(x, y)
    super(x,y)
    #if Mouse.on_screen? and mouse_jump
    #  new_x = x * 32 - ($game_map.display_x/4) + 16
    #  new_y = y * 32 - ($game_map.display_y/4) + 16
    #  Mouse.pos_set(new_x,new_y)
    #end
  end
  #--------------------------------------------------------------------------
  # Instantly moves the cursor to the coordinates if they are within the
  # boundary window (inside-rectangle 3 tiles away from window's edges).
  # Otherwise, moves the cursor to the edge of the boundary and will force a
  # screen scroll on the next update.
  #
  # Do note that if the screen scroll has to be forced, you will need to call
  # this method again until the cursor is within range to force an instant
  # jump to the desired location.
  #
  # This method is used for the cursor move actions which already handle the
  # above warning.
  #--------------------------------------------------------------------------
  def slide_to(x,y)
    # Do nothing if cursor is already here OR the cursor is currently moving
    return if @x == x && @y == y
    return if $game_map.display_x % 128 != 0 || $game_map.display_y % 128 != 0
    
    # If location is within the boundary box of the screen borders
    if x >= $game_map.display_x / 128 + 3 and x <= $game_map.display_x / 128 + 16
      @x = x
      @real_x = @x * 128 
    # If location is on the borders but can't scroll screen any further
    elsif ($game_map.display_x == 0 && x <= 3) || 
    ($game_map.display_x == ($game_map.width - 20) * 128 && x >= $game_map.width - 4)
      @x = x
      @real_x = @x * 128
    # If location is right of the cursor's location
    elsif x > @x
      # Places cursor on edge of boundary, forcing a screen scroll next frame
      @x = ($game_map.display_x + 2559) / 128 - 2
      @real_x = (@x-1) * 128
    # If location is left of the cursor's location
    elsif x < @x
      # Places cursor on edge of boundary, forcing a screen scroll next frame
      @x = $game_map.display_x / 128 + 2
      @real_x = (@x+1) * 128 
    end
     
    # Repeated logic above
    if y >= $game_map.display_y / 128 + 3 and y <= $game_map.display_y / 128 + 11
      @y = y
      @real_y = @y * 128
    elsif ($game_map.display_y == 0 && y <= 3) || 
    ($game_map.display_y == ($game_map.height - 15) * 128 && y >= $game_map.height - 4)
      @y = y
      @real_y = @y * 128
    elsif y > @y
      @y = ($game_map.display_y + 1919) / 128 - 2
      @real_y = (@y-1) * 128
    elsif y < @y
      @y = $game_map.display_y / 128 + 2
      @real_y = (@y+1) * 128
    end
  end
  #--------------------------------------------------------------------------
  # Moves the cursor's y-coordinate for bigger cursor graphics
  #--------------------------------------------------------------------------
  def cursor_displacement
    case @character_name
    when 'cursor' then return 0
    when 'silocursor' then return 64
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # Forcefully moves the cursor to a location on the map and, upon arriving,
  # performs an action via a Proc object.
  # process : Proc object that is to be called when cursor reaches x,y
  # wait : How long the cursor stays here before moving onto next location
  # end_process : Proc object called when the wait period is over but before
  #               the cursor moves to the next location
  # disable_control : If this is the last action in the list, this flag will
  #                 determine whether the cursor shall reappear and accept
  #                 player input after the end_process is executed
  #--------------------------------------------------------------------------
  def add_move_action(x, y, process = nil, wait = 0, end_process = nil, disable_control = false)
    # Push the location into array
    @moveto_locations.push([x,y])
    # Push action that will be performed when destination reached
    @moveto_actions.push([process, wait, end_process, disable_control])
    # If there is an end process
    case wait
    when WAIT_CURSOR_POWER, WAIT_CURSOR_ANIMATION
      $spriteset.watch_for_animation_end($spriteset.player_sprite)
    when WAIT_UNIT_POWER, WAIT_UNIT_ANIMATION
      $spriteset.watch_for_animation_end($game_map.get_unit(x,y).sprite)
    end
  end
  #--------------------------------------------------------------------------
  # Activates scroll mode, where the cursor is not visible as it moves around
  # quickly across the map. Activated during move actions and when the player
  # holds down B.
  # The parameter 'flag' can have the following values:
  #   false => Scroll mode is not active
  #   1     => Player is holding down B
  #   2     => Forced movement (e.g. move actions)
  #--------------------------------------------------------------------------
  def scroll_mode=(flag)
    return if @scroll_mode == flag
    @visible = flag ? false : true
    @scroll_mode = flag
    @move_speed = flag ? 6 : 5
  end
  
  
end

