=begin
_____________________
 Sprite_Range        \__________________________________________________________
 
 The glowing tiles that define move range, attack range, or anything else. Each
 sprite is a 32x32 graphic.
 
 Notes:
 * Need to find a faster way to utilize many of these at onces. Creating 100+ 
 of these things every time a unit requests a range takes a while.
 * Will probably switch to bitmap file for graphics and animation; solid colors
 are a placeholder
 
 Updates:
 - XX/XX/XX
 - 03/14/14
   + Trying out a new thing: pre-emptive drawing of these tiles so that it doesnt
     take so long to draw new ones everytime ranges are requested.
________________________________________________________________________________
=end
$sprite_range_bitmaps = []
for i in 0..3
  $sprite_range_bitmaps[i] = Bitmap.new(32,32)
  rect = Rect.new(0, 0, 32, 32)
  case i
  when 0 then $sprite_range_bitmaps[i].fill_rect(rect, Color.new(0, 0, 255, 255)) #Move
  when 1 then $sprite_range_bitmaps[i].fill_rect(rect, Color.new(255, 0, 0, 255)) #Ranges
  when 2 then $sprite_range_bitmaps[i].fill_rect(rect, Color.new(240, 0, 60, 255)) #Attack
  when 3 then $sprite_range_bitmaps[i].fill_rect(rect, Color.new(0, 255, 0, 255)) #Drop
  end
end
#===============================================================================
# Sprite Range - Used to display all "RANGES" during battle
#===============================================================================
class Sprite_Range < RPG::Sprite
  attr_accessor   :ox
  attr_accessor   :oy
  #----------------------------------------------------------------------------
  #Constants
  #----------------------------------------------------------------------------
  ANIM_FRAMES = 4
  #----------------------------------------------------------------------------
  # Object initialization
  #----------------------------------------------------------------------------
  #   type = 1-7, passed by 'def draw_ranges' from Scene_Battle_TBS
  #----------------------------------------------------------------------------
  def initialize(viewport, type, x, y, visible = true)
    super(viewport)
    self.visible = visible
    #self.bitmap = Bitmap.new(32,32)
    @wait = 6
    @pattern = [0,1,2,3]
    @p_index = 0 #pattern index
    @type = type
    @x = x; @y = y   # Denotes map's tile x/y
    self.zoom_x = 0
    self.zoom_y = 0
    @anim = false
    self.z = 20000

    moveto(@x, @y)
    refresh  
  end
  #----------------------------------------------------------------------------
  # Refresh - Process to update/set the bitmap for the object
  #----------------------------------------------------------------------------
  def refresh
    #create rectangle to fill is not using a picture
    rect = Rect.new(0, 0, 32, 32)
    
      if @anim
        case @type
        when 1; self.bitmap = RPG::Cache.picture(sprintf("GTBS/#{$game_system.attack_color}_range"))
        when 2; self.bitmap = RPG::Cache.picture(sprintf("GTBS/#{$game_system.move_color}_range"))
        end
      else
        case @type
        when 1
          self.bitmap = $sprite_range_bitmaps[0] 
          #self.bitmap.fill_rect(rect, Color.new(0, 0, 255, 255)) #Move
          self.opacity = 150
        when 2
          self.bitmap = $sprite_range_bitmaps[1]
          #self.bitmap.fill_rect(rect, Color.new(255, 0, 0, 255)) #Ranges
          self.opacity = 150
        when 3
          self.bitmap = $sprite_range_bitmaps[2]
          #self.bitmap.fill_rect(rect, Color.new(240, 0, 60, 255)) #Attack
          self.opacity = 200
        when 4
          self.bitmap = $sprite_range_bitmaps[3]
          #self.bitmap.fill_rect(rect, Color.new(0, 255, 0, 255)) #Drop
          self.opacity = 200
        end
      end
    if @anim
      @cw = self.bitmap.width / ANIM_FRAMES 
    else
      @cw = self.bitmap.width
    end
    @ch = self.bitmap.height
    update
  end
  #----------------------------------------------------------------------------
  # Dispose process
  #----------------------------------------------------------------------------
  def dispose
    unless self.bitmap == nil
      #self.bitmap.dispose    comment out if using the cached bitmaps
      self.bitmap = nil
    end
    super
  end
  #----------------------------------------------------------------------------
  # MoveTo - sets the current X,Y location on the map
  #----------------------------------------------------------------------------
  def moveto(x, y)
    #@ox = x; @oy = y
    @x = x % $game_map.width
    @y = y % $game_map.height
    #kk20
    @real_x = @x * 128 + 64
    @real_y = @y * 128 + 64
  end
  #----------------------------------------------------------------------------
  # Screen X - sets X based on current map position
  #----------------------------------------------------------------------------
  def screen_x
    x = ((@real_x - $game_map.display_x + 3) / 4)
    return x
  end
  #----------------------------------------------------------------------------
  # Screen Y - sets Y based on current map position
  #----------------------------------------------------------------------------
  def screen_y
    y = ((@real_y - $game_map.display_y + 3) / 4 ) 
    return y 
  end
  #----------------------------------------------------------------------------
  # Update Process
  #----------------------------------------------------------------------------
  def update
    
    #kk20
    if self.zoom_x != 1.0
      self.zoom_x += 0.125
      self.zoom_y += 0.125
      @real_x -= 8; @real_y -= 8
    end

    super unless self.disposed?
    update_animation if @anim
    update_bitmap if @anim
    update_location
    
    
  end
  #----------------------------------------------------------------------------
  # Update animation - used to progress the animation frame index
  #----------------------------------------------------------------------------
  def update_animation
    if @wait != 0
      @wait -= 1
      if @wait == 0
        @wait = 6
        #update frame every six updates
        @p_index += 1 
        if @p_index == @pattern.size
          @p_index = 0
        end
      end
    end
  end
  #----------------------------------------------------------------------------
  # Update bitmap based on pattern
  #----------------------------------------------------------------------------
  def update_bitmap
    sx = @pattern[@p_index] * @cw rescue sx = 0
    self.src_rect.set(sx, 0, @cw, @ch)
  end
  #----------------------------------------------------------------------------
  # Updates X, Y, Z coords
  #----------------------------------------------------------------------------
  def update_location
    self.x = screen_x unless self.disposed?
    self.y = screen_y unless self.disposed?
  end
  
  def reinit(type, x, y)
    self.visible = true
    self.zoom_x = 0
    self.zoom_y = 0
    @x = x
    @y = y
    moveto(@x, @y)
    if type != @type
      @type = type
      refresh 
    end
  end
  
end


