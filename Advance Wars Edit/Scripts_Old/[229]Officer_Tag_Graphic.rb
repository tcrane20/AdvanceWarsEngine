=begin
____________________________
 Officer_Tag_Graphic        \___________________________________________________
 
 The thing at the top of the screen that has the CO's face in it with a border.
 A new instance of this is created and destroyed at the start of each player's
 turn. Controls and creates the gold graphic and powerbar graphic as well.
 
 Notes:
 * How about we keep just one instance of this and reset it for each player?
 * Be sure to still allow multiple instances of these at once
 
 Updates:
 - 11/06/14
   + Confirming that the below issue still occurs. Made a fix attempt but it
     still happens when the cursor and screen are scrolling fast (i.e hold B)
 - 03/16/14
   + Fixed positioning. When making direct changes to cursor's real_x, could
     sometimes have the window on the same side as the cursor.
________________________________________________________________________________
=end
class Officer_Tag_Graphic < RPG::Sprite
  def initialize(viewport, army, on_map = true)
    super(viewport)
    # Create gold, Stars and Day
    @gold = Gold_Graphic.new(viewport, army)
    @powerbar = Powerbar_Graphic.new(viewport, army)
    @day = Day_Graphic.new(viewport)
    # Move graphic to left or right accordingly
    @phase = 0
    @old_cursor_rx = 0#$game_player.real_x
    @on_map = on_map  # If drawing this graphic on the map, updating its position on the screen
    self.mirror = true
    @army = army
    self.bitmap = Bitmap.new(89, 86)
    # Draw the border graphic
    bitmap = RPG::Cache.picture("officer_tag_" + @army.id.to_s)
    rect = Rect.new(0,0,89,28)
    self.bitmap.blt(0,34,bitmap,rect)
    # Draw officer graphic
    bitmap = RPG::Cache.picture("CO_" + @army.officer.name)
    rect = Rect.new(288,700,64,24) # Gets the officer's face graphic
    self.bitmap.blt(0,36,bitmap,rect)
    self.z = 8000
    # Draw the graphic in the right location
    update_position
  end
  #----------------------------------------------------------------------------
  # Update process
  #----------------------------------------------------------------------------
  def update
    return if disposed?
    super
    update_position if @on_map
    
    if $game_player.scroll_mode == 1
      self.visible = false
      @gold.visible = false
      @powerbar.visible = false
      @day.visible = false
    elsif !self.visible
      self.visible = true
      @gold.visible = true
      @powerbar.visible = true
      @day.visible = true
    end
    
    @gold.update
    @powerbar.update
    @day.update
    
  end
  #--------------------------------------------------------------------------
  # Updates the window's location. If cursor is too far left, puts window to right.
  # Because the powerbar graphic is going to be the longest thing, we change
  # its x-values first. Of course, later on, I'll need to have some kind of
  # check when, say, there are no CO Powers allowed, in which case, the tag
  # graphic is the longest thing.
  #--------------------------------------------------------------------------
  def update_position
    if !@on_map
      self.mirror = false
      @powerbar.reverse = false
      @gold.x = @powerbar.x
      @day.x = @powerbar.x
      self.x = @powerbar.x
      return
    end
    
    
    player_x = $game_player.real_x
    screen_x = $game_map.display_x
    # If cursor is going from one side of the screen to the other
    if (player_x - screen_x > 1152 and @old_cursor_rx - screen_x <= 1152) or 
    (player_x - screen_x < 1280 and @old_cursor_rx - screen_x >= 1280)
      @phase *= -1
      # Mirror graphic if the player crosses the border at exactly phase 0
      self.mirror = !self.mirror if @phase == 0
    end
    
    # If still sliding
    if @phase < 14
      # increment phase counter
      @phase += 1
      
      # Moving towards off screen
      if @phase < -1
        # if on left side of screen
        if !self.mirror
          @powerbar.x = case (@phase+1)/2
          # 2 ^ (case + 7)
            when -6 then @powerbar.width / 2 - @powerbar.width
            when -5 then @powerbar.width / 4 - @powerbar.width
            when -4 then @powerbar.width / 8 - @powerbar.width
            when -3 then @powerbar.width / 16 - @powerbar.width
            when -2 then @powerbar.width / 32 - @powerbar.width
            when -1 then @powerbar.width / 64 - @powerbar.width
          end
        else # on right side
          @powerbar.x = case (@phase+1)/2
          # 2 ^ (case + 7)
            when -6 then 640 - @powerbar.width / 2
            when -5 then 640 - @powerbar.width / 4
            when -4 then 640 - @powerbar.width / 8
            when -3 then 640 - @powerbar.width / 16
            when -2 then 640 - @powerbar.width / 32
            when -1 then 640 - @powerbar.width / 64
          end
        end
      # Moving in from off screen
      elsif @phase > 0
        # if on left side of screen
        if !self.mirror
          @powerbar.x = case (@phase+1)/2
          # (2 ^ case - 1) / 2 ^ case, unless case == 7, then 1
            when 1 then @powerbar.width / 2 - @powerbar.width
            when 2 then @powerbar.width * 3 / 4 - @powerbar.width
            when 3 then @powerbar.width * 7 / 8 - @powerbar.width
            when 4 then @powerbar.width * 15 / 16 - @powerbar.width
            when 5 then @powerbar.width * 31 / 32 - @powerbar.width
            when 6 then @powerbar.width * 63 / 64 - @powerbar.width
            when 7 then 0
          end
        else # on right side
          @powerbar.x = case (@phase+1)/2
          # (2 ^ case - 1) / 2 ^ case, unless case == 7, then 1
            when 1 then 640 - @powerbar.width / 2
            when 2 then 640 - @powerbar.width * 3 / 4
            when 3 then 640 - @powerbar.width * 7 / 8
            when 4 then 640 - @powerbar.width * 15 / 16
            when 5 then 640 - @powerbar.width * 31 / 32
            when 6 then 640 - @powerbar.width * 63 / 64
            when 7 then 640 - @powerbar.width
          end
        end
      # Off screen @phase = 
      else
        @powerbar.x = 640
        self.mirror = !self.mirror if @phase == 0
      end
    else # Phase is at 7
      @powerbar.x = 0 if !self.mirror
      @powerbar.x = 640 - @powerbar.width if self.mirror
    end
    
    @powerbar.reverse = self.mirror
    @gold.x = (!self.mirror ? @powerbar.x : (@powerbar.width - 92) + @powerbar.x)
    @day.x = (!self.mirror ? @powerbar.x : (@powerbar.width - @day.width) + @powerbar.x)
    self.x = (!self.mirror ? @powerbar.x : (@powerbar.width - 89) + @powerbar.x)
    
    @old_cursor_rx = player_x

  end
  #--------------------------------------------------------------------------
  # Disposes gold and officer tag graphics
  #--------------------------------------------------------------------------
  def dispose
    @gold.dispose
    @powerbar.dispose
    @day.dispose
    super
  end
end
