class Tilemap
  
  alias init_new_dll initialize
  def initialize(viewport = nil)
    init_new_dll(viewport)
    # Set up the DLL calls
    @@update = Win32API.new("RadialGlow", "DrawMapsBitmap2", "ppppp", "i")
    @@autotile_update = Win32API.new("RadialGlow", "UpdateAutotiles", "ppppp", "i")
    @@initial_draw = Win32API.new("RadialGlow", "DrawMapsBitmap", "ppppp", "i")
    Win32API.new("RadialGlow","InitEmptyTile","l","i").call(@empty_tile.object_id)
  end
  
  def tileset=(t)
    return if @tileset == t
    @tileset = t
    @glowing_tilesets = []
    glowing_data = []
    for i in 0..15
      @glowing_tilesets.push(t.clone)
      glowing_data.push(@glowing_tilesets[i].object_id)
    end
    
    table = []
    for i in 0...(8*35)
      table[i] = case i
      when 38..44, 72..75, 88..92, 104..108, 120..124, 136 then 1
      when 46..52, 80..83, 96..100, 112..116, 128..132, 144 then 2
      else
        0
      end
    end
    dll = Win32API.new('RadialGlow', 'RadialGlow', 'pp', 'i')
    dll.call(glowing_data.pack("L*"), table.pack("L*"))
    
    @first_update = true
    @glowy_frame = 0
  end
  
  
  
  
  def update_glowing_tileset
    return if Graphics.frame_count % 3 != 0
    @glowy_frame = (@glowy_frame + 1) % 16
    @first_update = true
  end
  
  
  
  
  #---------------------------------------------------------------------------
  # Update tilemap graphics
  #---------------------------------------------------------------------------
  def update(range_data=nil)
    return if range_data.nil?
    update_glowing_tileset
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
    tile_bms.push(@glowing_tilesets[@glowy_frame].object_id)
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
      @@initial_draw.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"), range_data.pack("L*"))
    elsif @shift != 0
      # Update for shifting
      @@update.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"), range_data.pack("L*"))
    end
    # Check for autotile updates
    if !autotile_need_update.index(true).nil?
      @@autotile_update.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"), range_data.pack("L*"))
    end
    # Reset shift flag
    @shift = 0
    
    #puts Time.now - t
  end
end
