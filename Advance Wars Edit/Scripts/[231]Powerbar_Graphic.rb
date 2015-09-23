=begin
_________________________
 Powerbar_Graphic        \______________________________________________________
 
 The bouncing, colorful stars at the top of the screen to indicate when a CO
 Power/Super Power is ready. There is a bit of configuration below already
 established, should the developer want to use circles instead of stars or
 something. Kinda messy. Also need to figure out what to do if (S)COPs are
 disabled (it'd probably error).
 
 Notes:
 * Optimize?
 * What if no powers allowed? How does it work then?
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
# Consists of a series of sprites that draw the CO Power bar. Each star is a
# new sprite instance.

class Powerbar_Graphic
  attr_reader :width, :x
  
  def initialize(viewport, army)
    @viewport = viewport
    # CONFIGURE -----------------------------------
    @sprite_graphic = RPG::Cache.picture('co_stars')
    # Dimensions configured as [x, y, width, height] of ONE star/text graphic
    @small_star_dim = [0,0,14,14]
    @large_star_dim = [0,28,16,18]
    @cop_text_dim   = [0,64,76,32]
    @scop_text_dim  = [76,64,112,32]
    # Height values used when drawing partially filled stars. Five elements mean
    # that the stars will fill up at 20% rates.
    @small_star_heights = [10, 8, 6, 4, 0]
    @large_star_heights = [12, 10, 8, 4, 0]
    @total_anim_frames  = 17
    @draw_loc     = [65,40]
    # ---------------------------------------------
    @army = army
    @width = 0 # assuming stars on left side of screen, distance from right side of farthest star to screen's left border
    @x = 0
    @old_charge = 0
    @star_sprites = []
    @full_charge_color = 0
    @frame = (Graphics.frame_count / (@total_anim_frames * 2)) % 2
    @cop_empty = Sprite.new(viewport)
    @cop_empty.z = 9000
    @scop_empty = Sprite.new(viewport)
    @scop_empty.z = 10000
    @visible = true
    init_stars
  end
  
  def dispose
    @sprite_graphic.dispose
    @cop_empty.dispose
    @scop_empty.dispose
    @star_sprites.each{|star| star.dispose}
  end
  
  def x=(amt)
    return if @x == amt
    difference = amt - @x
    @x = amt
    @cop_empty.x += difference
    @scop_empty.x += difference
    @star_sprites.each{|star| star.x += difference}
    @power_text.x += difference
  end
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def visible=(bool)
    #p "Set visible"
    @visible = bool
    #p [@old_charge < @army.officer.cop_stars, !@army.using_power?]
    @cop_empty.visible = (bool ? (@old_charge < @army.officer.cop_rate && !@army.using_power?) : false)
    @scop_empty.visible = (bool ? (@old_charge != @army.officer.scop_rate && !@army.using_power?) : false)
    @star_sprites.each{|star| star.visible = (bool && !@army.using_power?)}
    @power_text.visible = (bool && @army.using_power?)
    if @power_text.visible
      @power_text.src_rect.set(@cop_text_dim[0],(@frame)*@cop_text_dim[3] + @cop_text_dim[1],
                              @cop_text_dim[2],@cop_text_dim[3]) if @army.officer.cop
      @power_text.src_rect.set(@scop_text_dim[0],(@frame)*@scop_text_dim[3] + @scop_text_dim[1],
                              @scop_text_dim[2],@scop_text_dim[3]) if @army.officer.scop
      # fix its positioning
        if !@reversed
          @power_text.ox = 0
        else
          @power_text.ox = @draw_loc[0] - (@width - @draw_loc[0] - @power_text.width)
        end
      
    end
                            
  end
  
  def army=(army)
    @army = army
    @frame = 0
    @cop_empty.dispose
    @scop_empty.dispose
    @star_sprites.each{|s| s.dispose}
    @star_sprites.clear
    init_stars
  end
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def init_stars
    # Very common variable that will be used a lot
    num_large_stars = @army.officer.scop_stars - @army.officer.cop_stars
    # Initialize bitmaps for empty stars sprites
    width1 = @small_star_dim[2] * @army.officer.cop_stars
    width1 -= [(@army.officer.cop_stars - 1) * 2, 0].max
    @cop_empty.bitmap = Bitmap.new((width1 <= 0 ? 1 : width1), @small_star_dim[3])
    
    width2 = @large_star_dim[2] * num_large_stars
    width2 -= [(num_large_stars - 1) * 2, 0].max
    @scop_empty.bitmap = Bitmap.new((width2 <= 0 ? 1 : width2), @large_star_dim[3])
    
    @cop_empty.x, @cop_empty.y = @draw_loc[0], @draw_loc[1]
    @scop_empty.x, @scop_empty.y = [[@draw_loc[0] + width1 - 4, @draw_loc[0]].max, 0].max, @draw_loc[1] + (@small_star_dim[3] - @large_star_dim[3])
    # Create the small empty stars. Also, initialize charging small star sprites.
    rect = Rect.new(@small_star_dim[0],@small_star_dim[1],@small_star_dim[2],@small_star_dim[3])
    x = @draw_loc[0]
    for i in 0...@army.officer.cop_stars
      # Draw one empty star to the bitmap
      @cop_empty.bitmap.blt([i * (@small_star_dim[2]-2), 0].max, 0, @sprite_graphic, rect)
      # Create the charging star sprite
      sp = Sprite.new(@viewport)
      sp.bitmap = @sprite_graphic
      sp.src_rect = Rect.new(@small_star_dim[0] + @small_star_dim[2], 
        @small_star_dim[1], @small_star_dim[2], 0)
      sp.x = x
      sp.y = @draw_loc[1]
      sp.z = 9500
      @star_sprites.push(sp)
      # Increment drawing x coordinate
      x += @small_star_dim[2] - 2
    end
    # Create the large empty stars. Also, initialize charging large star sprites.
    rect = Rect.new(@large_star_dim[0],@large_star_dim[1],@large_star_dim[2],@large_star_dim[3])
    x = [x-2, @draw_loc[0]].max
    for i in 0...num_large_stars
      # Draw one empty star to the bitmap
      @scop_empty.bitmap.blt([i * (@large_star_dim[2]-2), 0].max, 0, @sprite_graphic, rect)
      # Create the charging star sprite
      sp = Sprite.new(@viewport)
      sp.bitmap = @sprite_graphic
      sp.src_rect = Rect.new(@large_star_dim[0] + @large_star_dim[2], 
        @large_star_dim[1], @large_star_dim[2], 0)
      sp.x = x
      sp.y = @scop_empty.y
      sp.z = 10500
      @star_sprites.push(sp)
      # Increment drawing x coordinate
      x += @large_star_dim[2] - 2
    end
    @width = [@star_sprites[-1].x + @large_star_dim[2], @draw_loc[0] + @scop_text_dim[2]].max
    @power_text = Sprite.new
    @power_text.bitmap = @sprite_graphic
    @power_text.visible = false
    @power_text.x = @draw_loc[0]
    @power_text.y = @draw_loc[1] - 12
    @power_text.z = 10000
    @reversed = false
    self.reverse = true
  end
  
  
  def reversed
    @reversed
  end
  
  def reverse=(val)
    return if @reversed == val
    @reversed = val
    
    if @reversed
      @star_sprites.each{|star|
      # x position of star relative to left screen border
      # width = 143
      # stars take up 78 pixels
        star.ox = 2 * (star.x - @x) + star.width - @width
        star.mirror = true
      }
      @cop_empty.ox = 2 * (@cop_empty.x - @x) + (@cop_empty.bitmap.width-1 == 0 ? 0 : @cop_empty.bitmap.width) - @width
      @cop_empty.mirror = true
      @scop_empty.ox = 2 * (@scop_empty.x - @x) + (@scop_empty.bitmap.width-1 == 0 ? 0 : @scop_empty.bitmap.width) - @width
      @scop_empty.mirror = true
      @power_text.ox = 2 * (@power_text.x - @x) + @power_text.width - @width
    else
      @star_sprites.each{|star|
        star.ox = 0
        star.mirror = false
      }
      @cop_empty.ox = 0
      @cop_empty.mirror = false
      @scop_empty.ox = 0
      @scop_empty.mirror = false
      @power_text.ox = 0
    end

  end
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def update
    return unless @visible
    update_color_change if Graphics.frame_count % 3 == 0
    if !@army.using_power? and @full_charge_color == 1
      update_bounce
    end

    return if @old_charge == @army.stored_energy
    @old_charge = @army.stored_energy
    update_fill_amounts
  end
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def update_color_change
    @frame += 1
    @frame %= @total_anim_frames
    
    if @army.using_power?
      # Call this only once
      if !@power_text.visible
        @power_text.src_rect.set(@cop_text_dim[0],(@frame)*@cop_text_dim[3] + @cop_text_dim[1],
                              @cop_text_dim[2],@cop_text_dim[3]) if @army.officer.cop
        @power_text.src_rect.set(@scop_text_dim[0],(@frame)*@scop_text_dim[3] + @scop_text_dim[1],
                              @scop_text_dim[2],@scop_text_dim[3]) if @army.officer.scop
        @power_text.visible = true
        @cop_empty.visible = false 
        @scop_empty.visible = false
        @star_sprites.each{|star| star.visible = false}
      else
        @power_text.src_rect.set(@cop_text_dim[0],(@frame)*@cop_text_dim[3] + @cop_text_dim[1],
                              @cop_text_dim[2],@cop_text_dim[3]) if @army.officer.cop
        @power_text.src_rect.set(@scop_text_dim[0],(@frame)*@scop_text_dim[3] + @scop_text_dim[1],
                              @scop_text_dim[2],@scop_text_dim[3]) if @army.officer.scop
        # fix its positioning
        if !@reversed
          @power_text.ox = 0
        else
          @power_text.ox = @draw_loc[0] - (@width - @draw_loc[0] - @power_text.width)
        end
      end
      return
    else
      # Call only once
      if @power_text.visible
        @power_text.visible = false
        @cop_empty.visible = true 
        @scop_empty.visible = true
        @star_sprites.each{|star| star.visible = true}
      end
    end
    
    @star_sprites.each_index{|i|
      star = @star_sprites[i]
      rect = star.src_rect
      if i < @army.officer.cop_stars
        star.src_rect.set((@frame + 1) * @small_star_dim[2] + @small_star_dim[0],
          rect.y, rect.width, rect.height)
        star.y = @small_star_dim[3] - rect.height + @cop_empty.y
      else
        star.src_rect.set((@frame + 1) * @large_star_dim[2] + @large_star_dim[0],
          rect.y, rect.width, rect.height)
        star.y = @large_star_dim[3] - rect.height + @scop_empty.y
      end
    }
  end
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def update_bounce
    for i in 0...@army.officer.scop_stars
      return if i >= @army.officer.cop_stars && @army.stored_energy != @army.officer.scop_rate
      star = @star_sprites[i]
      additional = 0
      case Graphics.frame_count % 32 / 2 - i
      when 1 then additional = -2
      when 2..4 then additional = -4
      when 5 then additional = -2
      else 
        additional = 0
      end
      star.y = @small_star_dim[3] - star.src_rect.height + @cop_empty.y + additional
    end
  end
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def update_fill_amounts
    # If all the stars are filled up, make the empty star graphics invisible
    # so that we can't see them when the stars move
    @cop_empty.visible = @old_charge < @army.officer.cop_rate && !@army.using_power?
    @scop_empty.visible = @old_charge != @army.officer.scop_rate && !@army.using_power?
    # Init variables
    star_index = 0
    charged = @old_charge
    if (@army.officer.cop_stars > 0 && charged >= @army.officer.cop_rate) ||
    charged == @army.officer.scop_rate
      @full_charge_color = 1
    else
      @full_charge_color = 0
    end

    s_ratio = 100 / @small_star_heights.size
    l_ratio = 100 / @large_star_heights.size
    # Draw the filled COP stars
    for i in 0...@army.officer.cop_stars
      # Determine what star to draw
      amount = charged / s_ratio
      amount = @small_star_heights.size if amount > @small_star_heights.size
      amount = [amount - 1, 0].max

      star = @star_sprites[star_index]
      star.src_rect.set(
        (@frame + 1) * @small_star_dim[2],
        @small_star_dim[1] + @small_star_heights[amount] + (@small_star_dim[3] * @full_charge_color),
        @small_star_dim[2], @small_star_dim[3] - @small_star_heights[amount])
      star.y = @small_star_dim[3] - star.src_rect.height + @cop_empty.y
      charged -= 100
      break if charged < s_ratio
      star_index += 1
    end
    return if charged < l_ratio
    # Draw the SCOP stars
    for i in 0...(@army.officer.scop_stars - @army.officer.cop_stars)
      # Determine what star to draw
      amount = charged / l_ratio
      amount = @large_star_heights.size if amount > @large_star_heights.size
      amount = [amount - 1, 0].max

      star = @star_sprites[star_index]
      star.src_rect.set(
        (@frame + 1) * @large_star_dim[2],
        @large_star_dim[1] + @large_star_heights[amount] + (@large_star_dim[3] * @full_charge_color), 
        @large_star_dim[2], @large_star_dim[3] - @large_star_heights[amount])
      star.y = @large_star_dim[3] - star.src_rect.height + @scop_empty.y
      charged -= 100
      break if charged < l_ratio
      star_index += 1
    end
  end
  
end