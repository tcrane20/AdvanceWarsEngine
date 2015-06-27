=begin
_______________
 Sprite        \________________________________________________________________
 
 Added a width method. Not sure why...
 
 Notes:
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Sprite
  def width
    return self.src_rect.width
  end
end
=begin
____________________
 RPG::Sprite        \___________________________________________________________
 
 Animations now have flags that indicate the exact moment the animation ends.
 Also adds a new blink effect and new animation type - loop back.
 
 Notes:
 
 Updates:
 - 11/08/14
   + Raised z layer of animations
 - 04/10/14
   + Cleaned up the code by aliasing copy-pasta methods (wow I was noob then).
     Retains RPG Maker blinking. Loop animations can loop back to a frame rather
     than start from the first frame.
________________________________________________________________________________
=end
module RPG
  class Sprite < ::Sprite
    
    #-------------------------------------------------------------------------
    # Initialize new variables
    #-------------------------------------------------------------------------
    alias init_new_blink_anims initialize
    def initialize(viewport = nil)
      @_blink_type = 0
      @_loop_back_frame = 0
      @_animation_done = false
      init_new_blink_anims(viewport)
    end
    #-------------------------------------------------------------------------
    # Allows blinking to have different types
    #-------------------------------------------------------------------------
    alias orig_blink_on blink_on
    def blink_on(type = 0)
      return if @_blink
      @_blink_type = type
      orig_blink_on
    end
    #-------------------------------------------------------------------------
    # Allows loop animations to return to a specific frame rather than the first
    #-------------------------------------------------------------------------
    alias set_loop_point_animation loop_animation
    def loop_animation(animation, loop_back_frame = 0)
      return if set_loop_point_animation(animation) == nil
      @_loop_back_frame = loop_back_frame
    end
    
    alias raise_animation_z animation_set_sprites
    def animation_set_sprites(sprites, cell_data, position)
      raise_animation_z(sprites, cell_data, position)
      sprites.each{|s| s.z = 100000}
    end
    
    def animation_set_sprites(sprites, cell_data, position)
      for i in 0..15
        sprite = sprites[i]
        pattern = cell_data[i, 0]
        if sprite == nil or pattern == nil or pattern == -1
          sprite.visible = false if sprite != nil
          next
        end
        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)
        if position == 3
          if self.viewport != nil
            sprite.x = self.viewport.rect.width / 2
            sprite.y = self.viewport.rect.height - 160
          else
            sprite.x = 320
            sprite.y = 240
          end
        else
          sprite.x = self.x - self.ox + self.src_rect.width / 2
          sprite.y = self.y - self.oy + self.src_rect.height / 2
          sprite.y -= self.src_rect.height / 4 if position == 0
          sprite.y += self.src_rect.height / 4 if position == 2
        end
        sprite.x += cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.z = 2000
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = cell_data[i, 3] / 100.0
        sprite.zoom_y = cell_data[i, 3] / 100.0
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    end
    
    
    #-------------------------------------------------------------------------
    # New update methods for blink and loop animations
    #-------------------------------------------------------------------------
    alias update_after_custom_stuff update
    def update
      # Reset the flag every update
      @_animation_done = false
      # Save flags for end
      blinking = @_blink
      looping  = @_loop_animation
      # If sprite is blinking
      if @_blink
        case @_blink_type
        # Default RMXP Blink
        when 0
          @_blink_count = (@_blink_count + 1) % 32
          if @_blink_count < 16
            alpha = (16 - @_blink_count) * 6
          else
            alpha = (@_blink_count - 16) * 6
          end
        # AW Super/CO Power blink
        when 1
          @_blink_count = (Graphics.frame_count + 1) % 80
          if @_blink_count < 40
            alpha = (40 - @_blink_count) * 5
          else
            alpha = (@_blink_count - 40) * 5
          end
        end
        # Set the color
        self.color.set(255, 255, 255, alpha)
        # Turn off blink flag temporarily
        @_blink = false
      end
      # If playing looping animation and need update
      if @_loop_animation != nil and (Graphics.frame_count % 3 == 0)
        update_loop_animation
        @_loop_animation_index += 1
        # If reached end of animation, jump back to looping point
        if @_loop_animation_index % @_loop_animation.frame_max == 0
          @_loop_animation_index = @_loop_back_frame
        end
        @_loop_animation = nil
      end
      # Call original update method
      update_after_custom_stuff
      # Reset the flags to what they originally were
      @_blink = blinking
      @_loop_animation = looping
    end
    #-------------------------------------------------------------------------
    # Turns flag on that animation ended
    #-------------------------------------------------------------------------
    alias animation_ends_flag dispose_animation
    def dispose_animation
      if @_animation_sprites != nil
        @_animation_done = true 
      end
      animation_ends_flag
    end
    #-------------------------------------------------------------------------
    # Modified to include a new method
    #-------------------------------------------------------------------------
    alias loop_animation_ends_flag dispose_loop_animation
    def dispose_loop_animation
      if @_loop_animation_sprites != nil
        @_animation_done = true 
      end
      
      loop_animation_ends_flag
    end
    #-------------------------------------------------------------------------
    # Returns true if the animation that was playing on this graphic has finally
    # finished. This value is set to false as soon as the sprite is updated again.
    #-------------------------------------------------------------------------
    def animation_end?
      return @_animation_done
    end
    
  end
end


