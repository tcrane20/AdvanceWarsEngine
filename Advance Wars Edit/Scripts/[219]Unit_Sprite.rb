=begin
____________________
 Unit_Sprite        \___________________________________________________________
 
 Very vital class. Draws the unit graphic onto the map. Also controls the HP
 and action flags on its bottom. This sprite needs to move around and play
 animations on itself.
 
 Notes:
 * Optimize badly
 * Maybe give it entire control to flag and health sprite so I don't need a
 class for those anymore
 * Resort to using just X/Y and real X/Y. No OX/OY
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Unit_Sprite < RPG::Sprite
  attr_accessor :is_moving
  attr_reader :unit
  #--------------------------------------------------------------------------
  # Initialize unit sprite, then call update
  #--------------------------------------------------------------------------
  def initialize(viewport, unit)
    super(viewport)
    # Initialize flag sprites (capturing, hiding, carrying, etc. and health)
    @flag = Flag_Sprite.new(unit, viewport)
    @health = Health_Sprite.new(unit, viewport)
    # Stores unit data
    @unit = unit
    # Reverse unit sprites every even numbered army
    self.mirror = true if @unit.army.id % 2 == 0
    # Set sprite location
    self.x = @unit.x * 32
    self.y = @unit.y * 32
    @real_x = self.x * 4
    @real_y = self.y * 4
    
    @anim_frame = @unit.frame
    @anim = false
    @is_moving = false    # If unit is currently undergoing move animation
    @running = false      # For moving animation purposes
    @move_route = []
    refresh
  end
  #----------------------------------------------------------------------------
  # Dispose flags
  #----------------------------------------------------------------------------
  def dispose_flags
    @flag.dispose
    @health.dispose
    @flag = @health = nil
  end
  
  def dispose
    dispose_flags unless (@flag.nil? || @health.nil?)
    super
  end
  
  #----------------------------------------------------------------------------
  # Plays an animation over the unit. The unit may be invisible or have a nil
  # bitmap, but it cannot be disposed.
  #----------------------------------------------------------------------------
  def play_animation(type)
    case type
    when 'destroy'
      case @unit.move_type
      when MOVE_AIR
        animation($data_animations[111], true)
      when MOVE_SEA,MOVE_TRANS
        animation($data_animations[110], true)
      else
        animation($data_animations[101], true)
      end
    when 'supply'
      player_x = $game_player.real_x
      screen_x = $game_map.display_x
      if player_x - screen_x >= 1280
        loop_animation($data_animations[104]) # Points right
      else
        loop_animation($data_animations[103], 5) # Points left
      end
    when 'repair'
      player_x = $game_player.real_x
      screen_x = $game_map.display_x
      if player_x - screen_x >= 1280
        loop_animation($data_animations[106]) # Points right
      else
        loop_animation($data_animations[105]) # Points left
      end
    when 'trap'
      player_x = $game_player.real_x
      screen_x = $game_map.display_x
      if player_x - screen_x >= 1280
        animation($data_animations[108], true) # Points right
      else
        animation($data_animations[107], true) # Points left
      end
    when 'power_0'
    when 'super_0'
      animation($data_animations[115], true)
    when 'silo'
      animation($data_animations[109], true)
    end
  end
  #----------------------------------------------------------------------------
  # Stops the animation playing over the unit
  #----------------------------------------------------------------------------
  def stop_loop_animation
    loop_animation(nil)
  end
  #----------------------------------------------------------------------------
  # Refresh - Process to update/set the bitmap for the object
  #----------------------------------------------------------------------------
  def refresh
    # get unit bitmap (picture folder)
    id = "_" + @unit.army.id.to_s
    self.bitmap = RPG::Cache.character(@unit.name + id, 0)
    # define unit sprite width and height (32 x 32)
    @cw = self.bitmap.width / 4 # four frames of animation
    @ch = self.bitmap.height
    update
  end
  #--------------------------------------------------------------------------
  # Update the unit graphic, both when moving and idle
  #--------------------------------------------------------------------------
  def update
    super
    unless @unit.needs_deletion #@unit.health > 0
      update_bitmap   # Update unit animation frame
      update_screen   # Update the position the graphic should be displayed
      update_frame    # Update the frame count and flag graphic
      update_movement if @is_moving # If unit is moving, update its movement
    end
  end
  #--------------------------------------------------------------------------
  # Updates the animation frame
  #--------------------------------------------------------------------------
  def update_bitmap
    # Get the graphic that represents the current frame
    sx = @unit.frame * @cw
    # Darken the sprite if it has acted
    self.color.set(0, 0, 0, 128) if @unit.acted
    # Take the square graphic from the rectangular picture
    self.src_rect.set(sx, 0, @cw, @ch)
    if !@unit.exposed? #or @unit.loaded
      self.opacity = 0
      @flag.opacity = 0
      @health.opacity = 0
    elsif $game_player.scroll_mode == 1
      self.opacity = 90
      @flag.opacity = 0
      @health.opacity = 0
    else
      self.opacity = 255
      @flag.opacity = 255
      @health.opacity = 255
    end
    # If CO power is on and unit has not moved, create flashing unit
    if @unit.army.using_power? and !@unit.acted
      blink_on(1)
    else
      blink_off
    end
    
  end
  #--------------------------------------------------------------------------
  # Updates the frame count
  #--------------------------------------------------------------------------
  def update_frame
    # If animation frame is different, change graphic
    if @unit.frame != Graphics.frame_count % 60 / 15
      @unit.frame = Graphics.frame_count % 60 / 15
    end
    #Update the flag graphic
    # Is $viewing ranges necessary?#
    unless @is_moving or @unit.selected
      @flag.moveto(@unit.x, @unit.y)
      @flag.update
      @health.moveto(@unit.x, @unit.y)
      @health.update
    else
      @flag.bitmap = nil
      @health.bitmap = nil
    end
    
  end
  #--------------------------------------------------------------------------
  # Updates the origin of the sprite (where it should be drawn)
  #--------------------------------------------------------------------------
  def update_screen
    unless self.disposed?
      self.x = screen_x 
      self.y = screen_y
      self.z = self.y + 64 + (@is_moving ? 1 : 0)
    end
  end

  #----------------------------------------------------------------------------
  # Screen X - sets X based on current map position
  #----------------------------------------------------------------------------
  def screen_x
    x = (@real_x - $game_map.display_x + 3) / 4
    return x
  end
  #----------------------------------------------------------------------------
  # Screen Y - sets Y based on current map position
  #----------------------------------------------------------------------------
  def screen_y
    y = (@real_y - $game_map.display_y + 3) / 4 
    return y 
  end
  #----------------------------------------------------------------------------
  # Sets up all the conditions before moving can begin
  #----------------------------------------------------------------------------
  def move(route)
    @move_route = route
    # Get path directions
    @directions = []

    if route.size > 0
      # If actually moving a unit via player command
      if route[0].is_a?(MoveTile)
        case [route[0].x - unit.x, route[0].y - unit.y]
          when [0, 1] then @directions.push(2)
          when [-1,0] then @directions.push(4)
          when [1, 0] then @directions.push(6)
          when [0,-1] then @directions.push(8)
        end
        route.each_index{|i| 
          break if i == route.size-1
          movetile = route[i]
          nexttile = route[i+1]
          case [nexttile.x - movetile.x, nexttile.y - movetile.y]
            when [0, 1] then @directions.push(2)
            when [-1,0] then @directions.push(4)
            when [1, 0] then @directions.push(6)
            when [0,-1] then @directions.push(8)
          end
        }
      # Moving unit through eventing or dropping (array of ints)
      else
        @directions = route
      end
    end

    @h_unit = nil
    # Play moving sound effect if moving
    Config.play_se(@unit.move_se) if route.size != 0
    # Flags for graphic purposes
    @is_moving = true
    $spriteset.unit_moving = true
  end
  #----------------------------------------------------------------------------
  # Updates movement of the unit
  #----------------------------------------------------------------------------
  def update_movement
    #p "Unit Z = #{self.z}"
    # Skip if the unit is carrying out movement
    if !@running
      # If there is a hidden unit at the next spot, prompt TRAP and stop processing
      if @move_route.size > 0
        case @directions[0]
        when 2 #down
          @h_unit = $game_map.get_unit(@unit.x, @unit.y+1) if ($game_map.get_unit(@unit.x, @unit.y+1).is_a?(Unit) and $game_map.get_unit(@unit.x, @unit.y+1).army != @unit.army)
        when 4 #left
          @h_unit = $game_map.get_unit(@unit.x-1, @unit.y) if ($game_map.get_unit(@unit.x-1, @unit.y).is_a?(Unit) and $game_map.get_unit(@unit.x-1, @unit.y).army != @unit.army)
        when 6 #right
          @h_unit = $game_map.get_unit(@unit.x+1, @unit.y) if ($game_map.get_unit(@unit.x+1, @unit.y).is_a?(Unit) and $game_map.get_unit(@unit.x+1, @unit.y).army != @unit.army)
        when 8 #up
          @h_unit = $game_map.get_unit(@unit.x, @unit.y-1) if ($game_map.get_unit(@unit.x, @unit.y-1).is_a?(Unit) and $game_map.get_unit(@unit.x, @unit.y-1).army != @unit.army)
        end
      end
      # The unit's direction unless there is a hidden unit at the next spot
      @dir = (@h_unit.nil? and !@move_route[0].nil? ? @directions.shift : 0)
      # Reduce unit's fuel based on terrain cost unless it encountered hidden unit
      # OR if route is a series of integers
      if @dir != 0 && @move_route[0].is_a?(MoveTile)
        @unit.fuel -= @move_route.shift.cost
      end
      
      @counter = 1
      case @dir
      when 2 then @real_y += 16
      when 4 then @real_x -= 16
      when 6 then @real_x += 16
      when 8 then @real_y -= 16
      else # when zero (TRAP or not moving)
        @counter = 7
      end
      @running = true
    else
      # Move the sprite to its destination slowly (4 frames per tile)
      @counter += 1
      case @dir
      when 2 then @real_y += 16
      when 4 then @real_x -= 16
      when 6 then @real_x += 16
      when 8 then @real_y -= 16
      end
      # Change the unit's (x,y) values since it reached the tile
      if @counter == 8
        @running = false
        case @dir
        when 2 then @unit.y+=1
        when 4 then @unit.x-=1
        when 6 then @unit.x+=1
        when 8 then @unit.y-=1
        end
        # Slide the cursor with the unit
        unless @unit.loaded or (@dir == 0 and @h_unit.nil?)
          #$game_player.slide_to(@unit.x, @unit.y)
          $game_player.add_move_action(@unit.x, @unit.y, nil,0,nil,true)
          #$game_player.x = @unit.x
          #$game_player.y = @unit.y
          #$game_player.real_x = @unit.x * 128
          #$game_player.real_y = @unit.y * 128
        end
        
        # When done moving the unit or encounter hidden unit
        if @move_route.size == 0 or !@h_unit.nil?
          # Play TRAP animation if hidden unit
          @h_unit.sprite.play_animation('trap') unless @h_unit.nil?
          @unit.trap = (!@h_unit.nil?)
          # Fade the movement SE
          #Audio.bgs_fade(300)
          Audio.bgs_stop
          # Turn off flags
          @is_moving = false
          $spriteset.unit_moving = false
          # Unload the unit
          @unit.loaded = false if @unit.loaded
          # Update the FOW
          $spriteset.update_fow
        end
      end # if @counter != 4
    end # end of if !@running
  end
  
  
  
end
