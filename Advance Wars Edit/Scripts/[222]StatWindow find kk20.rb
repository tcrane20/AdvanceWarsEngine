=begin
___________________
 StatWindow        \____________________________________________________________
 
 The black window at the bottom of the screen that shows tile info, unit info,
 and units being carried by said unit. It creates and controls all of these.
 
 Notes:
 * Optimize?
 
 Updates:
 - 11/06/14
   + Confirming that the below issue still occurs. Made a fix attempt but it
     still happens when the cursor and screen are scrolling fast (i.e hold B)
 - 03/16/14
   + Fixed positioning. When making direct changes to cursor's real_x, could
     sometimes have the tag on the same side as the cursor.
________________________________________________________________________________
=end
class StatWindow < RPG::Sprite
	
	def initialize(viewport=nil)
		super(viewport)
    # Create graphic and lower opacity
		self.bitmap = RPG::Cache.picture("info_bar")
		self.opacity = 128
    # Animation variables
    @phase = 0
    @old_cursor_rx = $game_player.real_x
    self.mirror = true
    @display_width = self.bitmap.width
		# Creates an instance of the sprites that will be inserted into the window
		@tile_sprite = Tile_Graphic.new
		@unit_sprite = Unit_Graphic.new#<-- Held units done by this class
		@damage_window = Damage_Window.new
    
		self.y = 384
    update_position
	end
	#--------------------------------------------------------------------------
	# Update the graphic
	#--------------------------------------------------------------------------
	def update
		super
    # Moves to left or right side depending on cursor
		update_position     
		# Updates visibility
		if $spriteset.unit_moving or $game_player.scroll_mode
			self.visible = false
			@tile_sprite.visible = false
			@unit_sprite.visible = false
			@unit_sprite.carried_sprites.visible = false
			@damage_window.visible = false
		else
			self.visible = true
			@tile_sprite.visible = true
			@unit_sprite.visible = true
			@unit_sprite.carried_sprites.visible = true
			@damage_window.visible = true
			# Update the information only when the stat bar is visible and on the
      # correct side of the screen
      if @phase >= 0
        @tile_sprite.update
        @unit_sprite.update
        @damage_window.update
      end
		end
		
	end
	#--------------------------------------------------------------------------
	# Updates the window's location. If cursor is too far left, puts window to right.
	#--------------------------------------------------------------------------
	def update_position
    
    if @phase >= 0
      @display_width = self.bitmap.width
      @display_width -= 64 if !@unit_sprite.carried_sprites.holding_exists
      @display_width -= 64 if !@unit_sprite.unit_exists
    end
    
    # kk20 
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
          self.x = case (@phase+1)/2
            when -6 then @display_width / 2 - self.bitmap.width
            when -5 then @display_width / 4 - self.bitmap.width
            when -4 then @display_width / 8 - self.bitmap.width
            when -3 then @display_width / 16 - self.bitmap.width
            when -2 then @display_width / 32 - self.bitmap.width
            when -1 then @display_width / 64 - self.bitmap.width
          end
        else # on right side
          self.x = case (@phase+1)/2
            when -6 then 640 - @display_width / 2
            when -5 then 640 - @display_width / 4
            when -4 then 640 - @display_width / 8
            when -3 then 640 - @display_width / 16
            when -2 then 640 - @display_width / 32
            when -1 then 640 - @display_width / 64
          end
        end
      # Moving in from off screen
      elsif @phase > 0
        # if on left side of screen
        if !self.mirror
          self.x = case (@phase+1)/2
            when 1 then @display_width / 2 - self.bitmap.width
            when 2 then @display_width * 3 / 4 - self.bitmap.width
            when 3 then @display_width * 7 / 8 - self.bitmap.width
            when 4 then @display_width * 15 / 16 - self.bitmap.width
            when 5 then @display_width * 31 / 32 - self.bitmap.width
            when 6 then @display_width * 63 / 64 - self.bitmap.width
            when 7 then @display_width - self.bitmap.width
          end
        else # on right side
          self.x = case (@phase+1)/2
            when 1 then 640 - @display_width / 2
            when 2 then 640 - @display_width * 3 / 4
            when 3 then 640 - @display_width * 7 / 8
            when 4 then 640 - @display_width * 15 / 16
            when 5 then 640 - @display_width * 31 / 32
            when 6 then 640 - @display_width * 63 / 64
            when 7 then 640 - @display_width
          end
        end
      # Off screen
      else
        self.x = 640
        self.mirror = !self.mirror if @phase == 0
      end
    else # Phase is at 7
      self.x = @display_width - self.bitmap.width if !self.mirror
      self.x = 640 - @display_width if self.mirror
    end
    
    # update info positions
    @tile_sprite.x = (self.mirror ? @display_width - 64 + self.x : self.width - @display_width + self.x)
    @unit_sprite.x = (self.mirror ? @display_width - 128 + self.x : self.width - @display_width + self.x + 64)
    @unit_sprite.carried_sprites.x = (self.mirror ? @display_width - 192 + self.x : self.width - @display_width + self.x + 128)
    @damage_window.x = (self.mirror ? @display_width + self.x - 128 - 64: self.width - @display_width + self.x)
    # store player's real_x for next time
    @old_cursor_rx = player_x

	end
	#----------------------------------------------------------------------------
	# Dispose process
	#----------------------------------------------------------------------------
	def dispose
		unless self.bitmap == nil
			self.bitmap.dispose
			self.bitmap = nil
		end
		super
	end
	
end