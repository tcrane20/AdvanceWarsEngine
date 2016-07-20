=begin
================================================================================
XPA Tilemap                                                      Version 0.1b
by KK20                                                          02 Nov 2014
________________________________________________________________________________

 [ Version History]
 
 Ver.      Date            Notes
 -----     -----------     ----------------------------------------------------
 0.1b  ... 02 Nov 2014 ... Initial release
________________________________________________________________________________

 [ Introduction ]
 
 In light of recent discoveries regarding the usage of RGSS3 in RPG Maker XP
 games, many users were left with a dilemma in choosing which Tilemap rewrite to
 use due to the vast differences between RGSS1's and RGSS3's Tilemap classes
 that would cause complications in this transition. I aimed to find the best
 Tilemap rewrite and decided that I would have to make my own. Like every other
 Tilemap rewrite before it, this implementation is in no ways perfect, boasting
 PROs and CONs.
 
 This script is intended to be used for RPG Maker XP games using the RGSS3
 library (unofficially coined RPG Maker XP Ace); however, it is entirely
 compatible with RPG Maker XP games in the RGSS1 library.
________________________________________________________________________________

 [ License ]
 
 This work is protected by the following license: 
 http://creativecommons.org/licenses/by-nc-sa/3.0/
 
********************************************************************************

You are free:

to Share - to copy, distribute and transmit the work
to Remix - to adapt the work

Under the following conditions:

Attribution:
You must attribute the work in the manner specified by the author or licensor, 
but not in any way that suggests that they endorse you or your use of the work.

Noncommercial:
You may not use this work for commercial purposes.

Share alike:
If you alter, transform, or build upon this work, you may distribute the 
resulting work only under the same or similar license to this one.

- For any reuse or distribution, you must make clear to others the license terms 
  of this work. The best way to do this is with a link to this web page.

- Any of the above conditions can be waived if you get permission from the 
  copyright holder.

- Nothing in this license impairs or restricts the author's moral rights.

********************************************************************************

 [ Instructions ]
 
 - Place this script below the default scripts but above Main.
 - Move 'XPATilemap.dll' into your project folder (same directory as 'Game.exe')
 - Configure values at the start of the script
 
 More detailed instructions can be found in the PDF that came with this script.
________________________________________________________________________________

 [ Features ]
 
 About the script:
 - XP and XPA (RGSS1 and RGSS3) compatible
 - Define your own custom resolution
 - Maps that are smaller than the game resolution are automatically centered
 - Drawing methods written in C-language, which has faster pixel-by-pixel
   operations than Ruby
 
 Add-ons:
 - Customize frame rate animation and define unique patterns for your autotiles
 - Remove unnecessary priority layers to boost frames-per-second (FPS)
 - Extend the default RPG::Weather class to fit larger screens, or not
 - more to add later...
________________________________________________________________________________

 [ Compatibility ]
 
 Unknown at this time...
________________________________________________________________________________

 [ Credits ]
 
 KK20 - Author of this script and DLL
 Zexion - Tester and morale support
 ForeverZer0 - Reusing code from his Custom Resolution script, found here:
                http://forum.chaos-project.com/index.php/topic,7814.0.html
 LiTTleDRAgo - Reusing code from his edits to Custom Resolution
________________________________________________________________________________

 [ Contact ]
 
 To contact the author of this script, please visit 
                http://forum.chaos-project.com/index.php
                
 or send an email to
                        tscrane20@gmail.com
                        
================================================================================
=end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                       B E G I N   C O N F I G U R A T I O N
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#-------------------------------------------------------------------------------
# The game window's screen resolution. RPG Maker XP's default is [640, 480].
# Do note that a larger resolution is prone to sprite lag.
#-------------------------------------------------------------------------------

SCREEN_RESOLUTION = [640,480]
#-------------------------------------------------------------------------------
# The largest level of priority your game uses. This value should be between
# 1 and 5. If using a large resolution, lowering the number of priority layers
# will help in reducing the lag.
#-------------------------------------------------------------------------------
MAX_PRIORITY_LAYERS = 2

#-------------------------------------------------------------------------------
# If using a larger resolution than 640x480, the default weather effects will
# look sparse as there are fewer sprites to cover a wider area. Setting this to
# TRUE will increase the number of sprites proportionally. This will create
# more lag as a result.
#-------------------------------------------------------------------------------
WEATHER_ADJUSTMENT = false

#-------------------------------------------------------------------------------
# Prevents the player from using ALT + ENTER to go into Fullscreen Mode. Note
# that this change applies to all applications on the player's computer.
#-------------------------------------------------------------------------------
DISABLE_ALT_ENTER = true

#-------------------------------------------------------------------------------
# Set the animation frame rate for autotiles. By default, all autotiles will
# update on the 16th frame. You can change that by providing an array of numbers
# that represent how many frames that particular frame on animation will be
# visible for.
#-------------------------------------------------------------------------------
def autotile_framerate(filename)
  case filename
  when '009-G2_Water01' then return [8,8,8,8]
  when '001-G_Water01' then return [20,20,20,20]
  when '024-Ocean01' then return [32,16,32,16]
  else
    # Generates array of [16, 16, ...] based on autotile width 
    # (or nil if not animating autotile)
    w = RPG::Cache.autotile(filename).width
    h = RPG::Cache.autotile(filename).height
    if (h == 32 && w / 32 == 1) || (h == 192 && w / 256 == 1)
      return nil
    else
      return h == 32 ? Array.new(w/32){|i| 16} : Array.new(w/256){|i| 16}
    end
  end
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#                                           E N D   C O N F I G U R A T I O N
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if DISABLE_ALT_ENTER
  # Disable ALT+Enter
  reghotkey = Win32API.new('user32', 'RegisterHotKey', 'LIII', 'I')
  reghotkey.call(0, 1, 1, 0x0D)
end

XPACE = false
if RUBY_VERSION == "1.9.2"
  XPACE = true
end

#===============================================================================
# ** Resolution
#===============================================================================

class Resolution
  
  attr_reader :version
  
  def initialize
    # Define version.
    @version = 0.93
    # Set instance variables for calling basic Win32 functions.
    ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
    title = "\0" * 256
    ini.call('Game', 'Title', '', title, 256, '.\\Game.ini')
    title.delete!("\0")
    @window = Win32API.new('user32', 'FindWindow', 'PP', 'I').call('RGSS Player', title)
    set_window_long = Win32API.new('user32', 'SetWindowLong', 'LIL', 'L')
    set_window_pos  = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
    @metrics         = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    # Set default size, displaying error if size is larger than the hardware.
    default_size = self.size 
    # Apply resolution change.
    x = (@metrics.call(0) - SCREEN_RESOLUTION[0]) / 2
    y = (@metrics.call(1) - SCREEN_RESOLUTION[1]) / 2
    set_window_long.call(@window, -16, 0x14CA0000)
    set_window_pos.call(@window, 0, x, y, SCREEN_RESOLUTION[0] + 6, SCREEN_RESOLUTION[1] + 26, 0)
    @window = Win32API.new('user32', 'FindWindow', 'PP', 'I').call('RGSS Player', title)
  end
  #--------------------------------------------------------------------------
  def size
    # Returns the screen size of the machine.
    return [@metrics.call(0), @metrics.call(1)]
  end
  #--------------------------------------------------------------------------
end

#===============================================================================
# ** RPG::Cache
#===============================================================================

module RPG::Cache
  
  AUTO_INDEX = [
  
  [27,28,33,34],  [5,28,33,34],  [27,6,33,34],  [5,6,33,34],
  [27,28,33,12],  [5,28,33,12],  [27,6,33,12],  [5,6,33,12],
  [27,28,11,34],  [5,28,11,34],  [27,6,11,34],  [5,6,11,34],
  [27,28,11,12],  [5,28,11,12],  [27,6,11,12],  [5,6,11,12],
  [25,26,31,32],  [25,6,31,32],  [25,26,31,12], [25,6,31,12],
  [15,16,21,22],  [15,16,21,12], [15,16,11,22], [15,16,11,12],
  [29,30,35,36],  [29,30,11,36], [5,30,35,36],  [5,30,11,36],
  [39,40,45,46],  [5,40,45,46],  [39,6,45,46],  [5,6,45,46],
  [25,30,31,36],  [15,16,45,46], [13,14,19,20], [13,14,19,12],
  [17,18,23,24],  [17,18,11,24], [41,42,47,48], [5,42,47,48],
  [37,38,43,44],  [37,6,43,44],  [13,18,19,24], [13,14,43,44],
  [37,42,43,48],  [17,18,47,48], [13,18,43,48], [13,18,43,48]
    
  ]
  
  def self.autotile(filename)
    key = "Graphics/Autotiles/#{filename}"
    if !@cache.include?(key) || @cache[key].disposed? 
      # Cache the autotile graphic.
      @cache[key] = (filename == '') ? Bitmap.new(128, 96) : Bitmap.new(key)
      # Cache each configuration of this autotile.
      new_bm = self.format_autotiles(@cache[key], filename)
      @cache[key].dispose
      @cache[key] = new_bm
    end
    return @cache[key]
  end

  def self.format_autotiles(bitmap, filename)
    if bitmap.height > 32 && bitmap.height < 256
      frames = bitmap.width / 96
      template = Bitmap.new(256*frames,192)
      # Create a bitmap to use as a template for creation.
      (0..frames-1).each{|frame|
      (0...6).each {|i| (0...8).each {|j| AUTO_INDEX[8*i+j].each {|number|
        number -= 1
        x, y = 16 * (number % 6), 16 * (number / 6)
        rect = Rect.new(x + (frame * 96), y, 16, 16)
        template.blt((32 * j + x % 32) + (frame * 256), 32 * i + y % 32, bitmap, rect)
      }}}}
      return template
    else
      return bitmap
    end
  end

end
#===============================================================================
# ** Resolution
#===============================================================================
class Viewport
  
  alias zer0_viewport_resize_init initialize
  def initialize(x=0, y=0, width=SCREEN_RESOLUTION[0], height=SCREEN_RESOLUTION[1], override=false)
    if x.is_a?(Rect)
      # If first argument is a Rectangle, just use it as the argument.
      zer0_viewport_resize_init(x)
    elsif [x, y, width, height] == [0, 0, 640, 480] && !override 
      # Resize fullscreen viewport, unless explicitly overridden.
      zer0_viewport_resize_init(Rect.new(0, 0, SCREEN_RESOLUTION[0], SCREEN_RESOLUTION[1]))
    else
      # Call method normally.
      zer0_viewport_resize_init(Rect.new(x, y, width, height))
    end
  end
  
  def resize(*args)
    # Resize the viewport. Can call with (X, Y, WIDTH, HEIGHT) or (RECT).
    self.rect = args[0].is_a?(Rect) ? args[0] : Rect.new(*args)
  end
end

#===============================================================================
# ** Tilemap
#===============================================================================
class Tilemap
  
  attr_accessor :tileset, :autotiles, :map_data, :priorities, :ground_sprite
  #---------------------------------------------------------------------------
  # Initialize
  #---------------------------------------------------------------------------
  def initialize(viewport = nil)
    @viewport = viewport
    @layer_sprites = []
    @autotile_frame = []      #[[ANIMATION_DRAW_INDEX, CURRENT_LOGICAL_FRAME], ... ]
    @autotile_framedata = []  #[[DATA_FROM_CONFIGURATION_ABOVE], ... ]
    
    # Ensures that the bitmap width accounts for an extra tile
    # and is divisible by 32
    bitmap_width = ((SCREEN_RESOLUTION[0] / 32.0).ceil + 1) * 32
    # Create the priority layers
    ((SCREEN_RESOLUTION[1]/32.0).ceil + MAX_PRIORITY_LAYERS).times{ |i|
      s = Sprite.new(@viewport)
      s.y = i*32 - (MAX_PRIORITY_LAYERS - 1) * 32
      s.z = 32 * (i+2)
      s.bitmap = Bitmap.new(bitmap_width, MAX_PRIORITY_LAYERS * 32)
      @layer_sprites.push(s)
    }
    
    # Same reasons as bitmap_width, but for height
    bitmap_height = ((SCREEN_RESOLUTION[1] / 32.0).ceil + 1) * 32
    # Create the ground layer (priority 0)
    s = Sprite.new(@viewport)
    s.bitmap = Bitmap.new(bitmap_width, bitmap_height)
    @ground_sprite = s
    @ground_sprite.z = 0
    
    # Initialize Autotile data
    $game_map.autotile_names.each_index{|i| filename = $game_map.autotile_names[i]
      # Get animation frame rate of the autotile
      frames = autotile_framerate(filename)
      # If autotile doesn't animate
      if frames.nil?
        @autotile_frame[i] = [0,0]
        @autotile_framedata[i] = nil
      else
        # Save the frame rate data
        @autotile_framedata[i] = frames
        # Determine how long one animation cycle takes and indicate at what time
        # the next frame of animation occurs
        total = 0
        frame_checkpoints = []
        frames.each_index{|j| f = frames[j]
          total += f
          frame_checkpoints[j] = total
        }
        # Get animation frame for this autotile based on game time passed
        current_frame = Graphics.frame_count % total
        frame_checkpoints.each_index{|j| c = frame_checkpoints[j]
          next if c.nil?
          if c > current_frame
            @autotile_frame[i] = [j, c - current_frame]
            break
          end
        }
      end
    }
    
    # Initialize remaining variables
    @first_update = true
    @tileset = nil
    @autotiles = []
    @map_data = nil
    @priorities = nil
    @old_ox = 0
    @old_oy = 0
    @ox = 0
    @oy = 0
    @shift = 0
    
    
    # Set up the DLL calls
    @@update = Win32API.new("XPATilemap", "DrawMapsBitmap2", "pppp", "i")
    @@autotile_update = Win32API.new("XPATilemap", "UpdateAutotiles", "pppp", "i")
    @@initial_draw = Win32API.new("XPATilemap", "DrawMapsBitmap", "pppp", "i")
    @empty_tile = Bitmap.new(32,32)
    Win32API.new("XPATilemap","InitEmptyTile","l","i").call(@empty_tile.object_id)
    
  end
  #---------------------------------------------------------------------------
  # Dispose tilemap
  #---------------------------------------------------------------------------
  def dispose
    @layer_sprites.each{|sprite| sprite.dispose}
    @ground_sprite.dispose
  end
  #---------------------------------------------------------------------------
  # Check if disposed tilemap
  #---------------------------------------------------------------------------
  def disposed?
    return @layer_sprites[0].disposed?
  end
  #---------------------------------------------------------------------------
  # Get viewport
  #---------------------------------------------------------------------------
  def viewport
    return @viewport
  end
  
  def color=(c)
    @ground_sprite.color = c
    @layer_sprites.each{|l| l.color = c}
  end
  
  def tileset=(t)
    return if @tileset == t
    @tileset = t
    @first_update = true
  end
  
  
  #---------------------------------------------------------------------------
  # Update tilemap graphics
  #---------------------------------------------------------------------------
  def update
    # t = Time.now
    autotile_need_update = []
    # Update autotile animation frames
    for i in 0..6
      autotile_need_update[i] = false
      # If this autotile doesn't animate, skip
      next if @autotile_framedata[i].nil?
      # Reduce frame count
      @autotile_frame[i][1] -= 1
      # Autotile requires update
      if @autotile_frame[i][1] == 0
        @autotile_frame[i][0] = (@autotile_frame[i][0] + 1) % @autotile_framedata[i].size
        @autotile_frame[i][1] = @autotile_framedata[i][@autotile_frame[i][0]]
        autotile_need_update[i] = true
      end
    end
    # If $game_map.data[]= script call was used, force redraw on entire map
    if self.map_data.changed
      @first_update = true
      self.map_data.changed = false
    end
    
    # Stop the update unless updating for first time or there are no shifting
    return if (!@first_update && @shift == 0 && autotile_need_update.index(true).nil?)

    # Set up the array for the priority layers
    layers = [@layer_sprites.size + 1]
    # Insert higher priority layers into the array in order (least to most y-value sprite)
    @layer_sprites.each{|sprite| layers.push(sprite.bitmap.object_id) }
    # Insert ground layer last in the array
    layers.push(@ground_sprite.bitmap.object_id)
    # Load autotile bitmap graphics into array
    tile_bms = [self.tileset.object_id]
    self.autotiles.each{|autotile| tile_bms.push(autotile.object_id) }
    # Store autotile animation frame data
    autotiledata = []
    for i in 0..6
      autotiledata.push(@autotile_frame[i][0])
      autotiledata.push(autotile_need_update[i] ? 1 : 0)
    end
    # Fills in remaining information of other tilemaps
    misc_data = [@ox + $game_screen.shake.to_i, @oy, self.map_data.object_id, self.priorities.object_id, @shift, MAX_PRIORITY_LAYERS]
    
    # If forcing fresh redraw of the map (or drawing for first time)
    if @first_update
      # Initialize layer sprite positions and clear them for drawing
      @layer_sprites.each_index{|i| layer = @layer_sprites[i]
        layer.bitmap.clear
        layer.x = -(@ox % 32)
        if layer.x <= -32 + $game_screen.shake.to_i
          layer.x += 32
        elsif layer.x > $game_screen.shake.to_i
          layer.x -= 32
        end
        layer.y = (i * 32) - (@oy % 32) - (MAX_PRIORITY_LAYERS-1) * 32
      }
      @ground_sprite.bitmap.clear
      @ground_sprite.x = -(@ox % 32)
      if @ground_sprite.x <= -32 + $game_screen.shake.to_i
        @ground_sprite.x += 32
      elsif @ground_sprite.x > $game_screen.shake.to_i
        @ground_sprite.x -= 32
      end
      @ground_sprite.y = -(@oy % 32)
      # Turn off flag to prevent calling this portion of code again
      @first_update = false
      # Make DLL call
      @@initial_draw.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"))
    elsif @shift != 0
      # Update for shifting
      @@update.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"))
    end
    # Check for autotile updates
    if !autotile_need_update.index(true).nil?
      @@autotile_update.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"))
    end
    # Reset shift flag
    @shift = 0
    
    #puts Time.now - t
  end
  #---------------------------------------------------------------------------
  # Return if tilemap is visible
  #---------------------------------------------------------------------------
  def visible
    return layer_sprites[0].visible
  end
  #---------------------------------------------------------------------------
  # Show or hide tilemap
  #---------------------------------------------------------------------------
  def visible=(bool)
    @layer_sprites.each{|sprite| sprite.visible = bool}
    @ground_sprite.visible = bool
  end
  
  #---------------------------------------------------------------------------
  # Shift tilemap horizontally
  #---------------------------------------------------------------------------
  def ox=(ox)
    # No shift = no need to continue
    return if @ox == ox && !$game_screen.shaking?
    # Compute difference and save change
    diff = @ox - ox
    @ox = ox
    # If forcing redraw, no need to shift layer sprites around
    return if @first_update
    
    # If shift is too big, force redraw
    if diff.abs > 32
      @first_update = true
      return
    end
    # Shift sprites
    @ground_sprite.x += diff
    @layer_sprites.each{|sprite| sprite.x += diff}

    # If sprites are out of bounds, reposition and redraw (make DLL call)
    if @ground_sprite.x <= -32 + $game_screen.shake.to_i
      @ground_sprite.x += 32
      @ground_sprite.bitmap.fill_rect(0, 0, 32, @ground_sprite.bitmap.height, Color.new(0,0,0,0))
      @layer_sprites.each{|sprite| 
        sprite.x += 32
        sprite.bitmap.fill_rect(0, 0, 32, sprite.bitmap.height, Color.new(0,0,0,0))
      }
      @shift += 1 # Redraw right column
    elsif @ground_sprite.x > 0 + $game_screen.shake.to_i
      @ground_sprite.x -= 32
      @ground_sprite.bitmap.fill_rect(@ground_sprite.bitmap.width - 32, 0, 32, @ground_sprite.bitmap.height, Color.new(0,0,0,0))
      @layer_sprites.each{|sprite| 
        sprite.x -= 32
        sprite.bitmap.fill_rect(sprite.bitmap.width - 32, 0, 32, sprite.bitmap.height, Color.new(0,0,0,0))
      }
      @shift += 2 # Redraw left column
    end
  end
  #---------------------------------------------------------------------------
  # Shift tilemap vertically
  #---------------------------------------------------------------------------
  def oy=(oy)
    return if @oy == oy
    diff = @oy - oy
    @oy = oy
    # If shift is too big, force redraw
    if diff.abs > 32
      @first_update = true
      return
    end
    # Shift sprites
    @ground_sprite.y += diff
    @layer_sprites.each{ |sprite|
      sprite.y += diff
      sprite.z += diff
    }
    # If ground is out of bounds, reshift and redraw (make DLL call)
    if @ground_sprite.y <= -32
      @ground_sprite.y += 32
      @shift += 4 # Redraw bottom row
    elsif @ground_sprite.y > 0
      @ground_sprite.y -= 32
      @shift += 8 # Redraw top row
    end

    # If layer is too far up screen, need to move it down
    if @layer_sprites[0].y <= -(MAX_PRIORITY_LAYERS * 32)
      shift_amt = ((SCREEN_RESOLUTION[1]/32.0).ceil + MAX_PRIORITY_LAYERS) * 32
      layer = @layer_sprites.shift
      layer.y += shift_amt
      layer.z += shift_amt
      layer.bitmap.clear
      @layer_sprites.push(layer)
    end
    # If layer is too far down screen, need to move it up
    if @layer_sprites[-1].y > ((SCREEN_RESOLUTION[1]/32.0).ceil * 32)
      shift_amt = ((SCREEN_RESOLUTION[1]/32.0).ceil + MAX_PRIORITY_LAYERS) * -32
      layer = @layer_sprites.pop
      layer.y += shift_amt
      layer.z += shift_amt
      layer.bitmap.clear
      @layer_sprites.unshift(layer)
    end
  end
end

#===============================================================================
# ** Game_Player
#===============================================================================
=begin
class Game_Player
  
  CENTER_X = ((SCREEN_RESOLUTION[0] / 2) - 16) * 4    # Center screen x-coordinate * 4
  CENTER_Y = ((SCREEN_RESOLUTION[1] / 2) - 16) * 4    # Center screen y-coordinate * 4
  
  def center(x, y)
    # Recalculate the screen center based on the new resolution.
    max_x = ($game_map.width - (SCREEN_RESOLUTION[0]/32.0).ceil) * 128
    max_y = ($game_map.height - (SCREEN_RESOLUTION[1]/32.0).ceil) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end  
end
=end
#===============================================================================
# ** Game_Map
#===============================================================================
class Game_Map
  alias zer0_map_edge_setup setup
  def setup(*args)
    zer0_map_edge_setup(*args)
    # Find the displayed area of the map in tiles. No calcualting every step.
    @map_edge = [self.width - (SCREEN_RESOLUTION[0]/32.0).ceil, self.height - (SCREEN_RESOLUTION[1]/32.0).ceil]
    @map_edge.collect! {|size| size * 128 }
=begin    
    if $game_map.width < SCREEN_RESOLUTION[0] / 32
      Game_Player.const_set(:CENTER_X, $game_map.width * 128)
    else
      Game_Player.const_set(:CENTER_X, ((SCREEN_RESOLUTION[0] / 2) - 16) * 4)
    end
    
    if $game_map.height < SCREEN_RESOLUTION[1] / 32
      Game_Player.const_set(:CENTER_Y, $game_map.height * 128)
    else
      Game_Player.const_set(:CENTER_Y, ((SCREEN_RESOLUTION[1] / 2) - 16) * 4)
    end
=end
  end

  def scroll_down(distance)
    # Find point that the map edge meets the screen edge, using custom size.
    @display_y = [@display_y + distance, @map_edge[1]].min
  end

  def scroll_right(distance)
    # Find point that the map edge meets the screen edge, using custom size.
    @display_x = [@display_x + distance, @map_edge[0]].min
  end
end
#===============================================================================
# ** Plane
#===============================================================================
Object.send(:remove_const, :Plane)
class Plane < Sprite
 
  def z=(z)
    # Change the Z value of the viewport, not the sprite.
    super(z * 1000)
  end
 
  def ox=(ox)
    return if @bitmap == nil
    # Have viewport stay in loop on X-axis.
    super(ox % @bitmap.width)
  end
 
  def oy=(oy)
    return if @bitmap == nil
    # Have viewport stay in loop on Y-axis.
    super(oy % @bitmap.height)
  end
 
  def bitmap
    # Return the single bitmap, before it was tiled.
    return @bitmap
  end
 
  def bitmap=(tile)
    @bitmap = tile
    # Calculate the number of tiles it takes to span screen in both directions.
    xx = 1 + (SCREEN_RESOLUTION[0].to_f / tile.width).ceil
    yy = 1 + (SCREEN_RESOLUTION[1].to_f / tile.height).ceil
    # Create appropriately sized bitmap, then tile across it with source image.
    plane = Bitmap.new(@bitmap.width * xx, @bitmap.height * yy)
    (0..xx).each {|x| (0..yy).each {|y|
      plane.blt(x * @bitmap.width, y * @bitmap.height, @bitmap, @bitmap.rect)
    }}
    # Set the bitmap to the sprite through its super class (Sprite).
    super(plane)
  end
 
  # Redefine methods dealing with coordinates (defined in super) to do nothing.
  def x; end
  def y; end
  def x=(x); end
  def y=(y); end
end

#===============================================================================
# ** Table
#===============================================================================
class Table
  attr_accessor :changed
  
  alias init_for_changed initialize
  def initialize(*args)
    init_for_changed(*args)
    @changed = false
  end
  
  alias flag_changes_to_set []=
  def []=(x, y, z=nil, v=nil)
    if v.nil?
      if z.nil?
        flag_changes_to_set(x, y)
      else
        flag_changes_to_set(x, y, z)
      end
    else
      @changed = true
      flag_changes_to_set(x, y, z, v)
    end
  end
  
end
#===============================================================================
# ** RPG::Weather
#===============================================================================
class RPG::Weather
  
  if WEATHER_ADJUSTMENT
    
  alias add_more_weather_sprites initialize
  def initialize(vp = nil)
    add_more_weather_sprites(vp)
    total_sprites = SCREEN_RESOLUTION[0] * SCREEN_RESOLUTION[1] / 7680
    if total_sprites > 40
      for i in 1..(total_sprites - 40)
        sprite = Sprite.new(vp)
        sprite.z = 1000
        sprite.visible = false
        sprite.opacity = 0
        @sprites.push(sprite)
      end
    end
  end
  
  def type=(type)
    return if @type == type
    @type = type
    case @type
    when 1
      bitmap = @rain_bitmap
    when 2
      bitmap = @storm_bitmap
    when 3
      bitmap = @snow_bitmap
    else
      bitmap = nil
    end
    for i in 1..@sprites.size
      sprite = @sprites[i]
      if sprite != nil
        sprite.visible = (i <= @max)
        sprite.bitmap = bitmap
      end
    end
  end
  
  def max=(max)
    return if @max == max;
    @max = [[max, 0].max, @sprites.size].min
    for i in 1..@sprites.size
      sprite = @sprites[i]
      if sprite != nil
        sprite.visible = (i <= @max)
      end
    end
  end

  end # WEATHER_ADJUSTMENT  
  
  def update
    return if @type == 0
    for i in 1..@max
      sprite = @sprites[i]
      if sprite == nil
        break
      end
      if @type == 1
        sprite.x -= 2
        sprite.y += 16
        sprite.opacity -= 8
      end
      if @type == 2
        sprite.x -= 8
        sprite.y += 16
        sprite.opacity -= 12
      end
      if @type == 3
        sprite.x -= 2
        sprite.y += 8
        sprite.opacity -= 8
      end
      x = sprite.x - @ox
      y = sprite.y - @oy
      if sprite.opacity < 64
        sprite.x = rand(SCREEN_RESOLUTION[0] + 100) - 100 + @ox
        sprite.y = rand(SCREEN_RESOLUTION[0] + 200) - 200 + @oy
        sprite.opacity = 160 + rand(96)
      end
    end
  end
  
end
#===============================================================================
# ** Game_Screen
#===============================================================================
class Game_Screen
  #--------------------------------------------------------------------------
  # * Set Weather
  #     type : type
  #     power : strength
  #     duration : time
  #--------------------------------------------------------------------------
=begin
  def weather(type, power, duration)
    @weather_type_target = type
    if @weather_type_target != 0
      @weather_type = @weather_type_target
    end
    if @weather_type_target == 0
      @weather_max_target = 0.0
    else
      if WEATHER_ADJUSTMENT
        num = SCREEN_RESOLUTION[0] * SCREEN_RESOLUTION[1] / 76800.0
      else
        num = 4.0
      end
      
      @weather_max_target = (power + 1) * num
    end
    @weather_duration = duration
    if @weather_duration == 0
      @weather_type = @weather_type_target
      @weather_max = @weather_max_target
    end
  end
=end 
  
  def shaking?
    return @shake_duration > 0 || @shake != 0
  end
  
end
#===============================================================================
# ** Spriteset_Map
#===============================================================================
class Spriteset_Map

  alias init_for_centered_small_maps initialize
  #---------------------------------------------------------------------------
  # Resize and reposition viewport so that it fits smaller maps
  #---------------------------------------------------------------------------
  def initialize
    @center_offsets = [0,0]
    if $game_map.width < SCREEN_RESOLUTION[0] / 32
      x = (SCREEN_RESOLUTION[0] - $game_map.width * 32) / 2
    else
      x = 0
    end
    if $game_map.height < SCREEN_RESOLUTION[1] / 32
      y = (SCREEN_RESOLUTION[1] - $game_map.height * 32) / 2
    else
      y = 0
    end
    init_for_centered_small_maps
    w = [$game_map.width  * 32 , SCREEN_RESOLUTION[0]].min
    h = [$game_map.height * 32 , SCREEN_RESOLUTION[1]].min
    @viewport1.resize(x,y,w,h)
  end

end

#------------------------------------------------------------------------------

$resolution = Resolution.new