#==============================================================================
# ÃÂ¢ÃÂÃÂ  Window - Hidden RGSS Class
#------------------
# ÃÂ£ÃÂÃÂby Selwyn
#==============================================================================

#==============================================================================
# ÃÂ¢ÃÂÃÂ  Bitmap
#==============================================================================

class Bitmap
  #--------------
  # ÃÂ¢ÃÂÃÂ erase
  #--------------
  def erase(*args)
    if args.size == 1
      rect = args[0]
    elsif args.size == 4
      rect = Rect.new(*args)
    end
    fill_rect(rect, Color.new(0, 0, 0, 0))
  end
end

#==============================================================================
# ÃÂ¢ÃÂÃÂ  SG::Skin
#==============================================================================

class Skin
  #--------------
  # ÃÂ¢ÃÂÃÂ instances settings
  #--------------
  attr_reader   :margin
  attr_accessor :bitmap
  #--------------
  # ÃÂ¢ÃÂÃÂ initialize
  #--------------
  def initialize
    @bitmap = nil
    @values = {}
    @values['bg'] = Rect.new(0, 0, 128, 128)
    @values['pause0'] = Rect.new(160, 64, 16, 16)
    @values['pause1'] = Rect.new(176, 64, 16, 16)
    @values['pause2'] = Rect.new(160, 80, 16, 16)
    @values['pause3'] = Rect.new(176, 80, 16, 16)
    @values['arrow_up'] = Rect.new(152, 16, 16, 8)
    @values['arrow_down'] = Rect.new(152, 40, 16, 8)
    @values['arrow_left'] = Rect.new(144, 24, 8, 16)
    @values['arrow_right'] = Rect.new(168, 24, 8, 16)
    self.margin = 5
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ width
  #--------------
  def margin=(width)
    @margin = width
    set_values
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ set_values
  #--------------
  def set_values
    w = @margin
    @values['ul_corner'] = Rect.new(128, 0, w, w)
    @values['ur_corner'] = Rect.new(192-w, 0, w, w)
    @values['dl_corner'] = Rect.new(128, 64-w, w, w)
    @values['dr_corner'] = Rect.new(192-w, 64-w, w, w)
    @values['up'] = Rect.new(128+w, 0, 64-2*w, w)
    @values['down'] = Rect.new(128+w, 64-w, 64-2*w, w)
    @values['left'] = Rect.new(128, w, w, 64-2*w)
    @values['right'] = Rect.new(192-w, w, w, 64-2*w)
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ []
  #--------------
  def [](value)
    return @values[value]
  end
end


#==============================================================================
# ÃÂ¢ÃÂÃÂ  SG::Cursor_Rect
#==============================================================================

class Cursor_Rect < ::Sprite
  #--------------
  # ÃÂ¢ÃÂÃÂ instances settings
  #--------------
  attr_reader   :height, :width, :skin, :margin
  #--------------
  # ÃÂ¢ÃÂÃÂ initialize
  #--------------
  def initialize(viewport)
    super(viewport)
    @width = 0
    @height = 0
    @skin = nil
    @margin = 0
    @hide_cursor = false
    @rect = {}
=begin
   @rect['cursor_up'] = Rect.new(129, 64, 30, 1)
   @rect['cursor_down'] = Rect.new(129, 95, 30, 1)
   @rect['cursor_left'] = Rect.new(128, 65, 1, 30)
   @rect['cursor_right'] = Rect.new(159, 65, 1, 30)
   @rect['upleft'] = Rect.new(128, 64, 1, 1)
   @rect['upright'] = Rect.new(159, 64, 1, 1)
   @rect['downleft'] = Rect.new(128, 95, 1, 1)
   @rect['downright'] = Rect.new(159, 95, 1, 1)
   @rect['bg'] = Rect.new(129, 65, 30, 30)
=end
    @rect['upleft'] = Rect.new(128, 64, 16, 16)
    @rect['upright'] = Rect.new(144, 64, 16, 16)
    @rect['downleft'] = Rect.new(128, 80, 16, 16)
    @rect['downright'] = Rect.new(144, 80, 16, 16)
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ margin=
  #--------------
  def margin=(margin)
    @margin = margin
    set(x, y, width, height)
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ skin=
  #--------------
  def skin=(skin)
    @skin = skin
    draw_rect
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ width=
  #--------------
  def width=(width)
    return if @width == width
    @width = width
    if @width == 0 and self.bitmap != nil
      self.bitmap.dispose
      self.bitmap = nil
    end
    draw_rect
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ height=
  #--------------
  def height=(height)
    return if @height == height
    @height = height
    if @height == 0 and self.bitmap != nil
      self.bitmap.dispose
      self.bitmap = nil
    end
    draw_rect
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ set
  # This method is called in Window_Selectable when updating the position of the
  # cursor. It is this method that determines whether or not to make a cursor
  # graphic visible to the player.
  #--------------
  def set(x, y, width, height)
    self.x = x
    self.y = y
    if @width != width or @height != height
      @width = width
      @height = height
      if width > 0 and height > 0
        draw_rect
      end
    end
  end
  
  def hide_cursor=(bool)
    
  end
  
  #--------------
  # ÃÂ¢ÃÂÃÂ empty
  #--------------
  def empty
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ draw_rect
  #--------------
  def draw_rect(frame = 0)
    return if @skin == nil
    if @width > 0 and @height > 0
      # Clear bitmap by making a new one
      self.bitmap = Bitmap.new(@width, @height)
      # Draw the cursor
      self.bitmap.blt(0 + frame, 0 + frame, @skin, @rect['upleft'])
      self.bitmap.blt(@width-16 - frame, 0 + frame, @skin, @rect['upright'])
      self.bitmap.blt(0 + frame, @height-16 - frame, @skin, @rect['downleft'])
      self.bitmap.blt(@width-16 - frame, @height-16 - frame, @skin, @rect['downright'])
      
    end
  end
  #------------
  #For Blizz's Mouse Script
  #------------
  def clone
    return Rect.new(self.x, self.y, self.width, self.height)
  end
end

#==============================================================================
# ÃÂ¢ÃÂÃÂ  SG::Window
#------------------
# ÃÂ£ÃÂÃÂ
#==============================================================================

class Window
  #--------------
  # ÃÂ¢ÃÂÃÂ set instances variables
  #--------------
  attr_reader(:x, :y, :z, :width, :height, :ox, :oy, :opacity, :back_opacity,
    :stretch, :contents_opacity, :visible, :pause, :pause_s)
  attr_reader :active
  #--------------
  # ÃÂ¢ÃÂÃÂ initialize
  #--------------
  def initialize()
    @frame_count = 0
    @skin = Skin.new
    @viewport = Viewport.new(0, 0, 0, 0)
    @cr_vport = Viewport.new(0, 0, 0, 0)
    @width = 0
    @height = 0
    @ox = 0
    @oy = 0
    @opacity = 255
    @back_opacity = 255
    @contents_opacity = 255
    @frame   = Sprite.new()
    @bg      = Sprite.new()
    @window  = Sprite.new(@viewport)
    @pause_s = Sprite.new()
    @arrows = []
    for i in 0...4
      @arrows.push(Sprite.new(@cr_vport))
      @arrows[i].bitmap = Bitmap.new(16, 16)
      @arrows[i].visible = false
    end
    @cursor_rect = Cursor_Rect.new(@cr_vport)
    @cursor_rect.margin = @skin.margin
    @pause_s.visible = false
    @pause = false
    @active = true
    @stretch = false
    @visible = true
    self.x = 0
    self.y = 0
    self.z = 100
    self.windowskin = RPG::Cache.windowskin($game_system.windowskin_name)
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ contents=
  #--------------
  def contents=(bmp)
    @window.bitmap = bmp
    if bmp != nil
      if bmp.width > @viewport.rect.width
        bmp.height > @viewport.rect.height
        draw_arrows
      end
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ contents
  #--------------
  def contents
    return @window.bitmap
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ dispose
  #--------------
  def dispose
    @bg.dispose
    @frame.dispose
    @window.dispose
    @cursor_rect.dispose
    @viewport.dispose
    @pause_s.dispose
    @cr_vport.dispose
    for arrow in @arrows
      arrow.dispose
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ disposed?
  #--------------
  def disposed?
    return false unless @bg.disposed?
    return false unless @frame.disposed?
    return false unless @window.disposed?
    return false unless @cursor_rect.disposed?
    return false unless @viewport.disposed?
    return false unless @pause_s.disposed?
    return false unless @cr_vport.disposed?
    for arrow in @arrows
      return false unless arrow.disposed?
    end
    return true
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ update
  #--------------
  def update
    @window.update
    @cursor_rect.update
    @viewport.update
    @cr_vport.update
    @pause_s.src_rect = @skin["pause#{(Graphics.frame_count / 8) % 4}"]
    @pause_s.update
    update_visible
    update_arrows
    # Updates the moving cursor
    @frame_count += 1
    update_cursor
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ update_cursor=
  #--------------
  def update_cursor(instant_draw=false)
    # Draw the cursor now (due to @active being newly set to true/false)
    if instant_draw
      case @frame_count
      when 0..30
        @cursor_rect.draw_rect
      when 31..33,37..39
        @cursor_rect.draw_rect(2)
      when 34..36
        @cursor_rect.draw_rect(4)
      end
    else
      if @frame_count == 31 or @frame_count == 37
        @cursor_rect.draw_rect(2)
      elsif @frame_count == 34
        @cursor_rect.draw_rect(4)
      elsif @frame_count == 40
        @cursor_rect.draw_rect
        @frame_count = 0
      end
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ update_visible
  #--------------
  def update_visible
    @frame.visible = @visible
    @bg.visible = @visible
    @window.visible = @visible
    @cursor_rect.visible = @visible
    if @pause
      @pause_s.visible = @visible
    else
      @pause_s.visible = false
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ active=
  #--------------
  def active=(bool)
    @active = bool
  end
=begin
  def active=(bool)
    return if @active == bool
    @active = bool
    @cursor_rect.visible = bool
    # Draw the rect cursor
    update_cursor(true)
  end
=end
  #--------------
  # ÃÂ¢ÃÂÃÂ pause=
  #--------------
  def pause=(pause)
    @pause = pause
    update_visible
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ update_arrows
  #--------------
  def update_arrows
    if @window.bitmap == nil or @visible == false
      for arrow in @arrows
        arrow.visible = false
      end
    else
      @arrows[0].visible = @oy > 0
      @arrows[1].visible = @ox > 0
      @arrows[2].visible = (@window.bitmap.width - @ox) > @width#@viewport.rect.width
      @arrows[3].visible = (@window.bitmap.height - @oy) > @height#@viewport.rect.height
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ visible=
  #--------------
  def visible=(visible)
    @visible = visible
    update_visible
    update_arrows
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ x=
  #--------------
  def x=(x)
    @x = x
    @bg.x = x + 2
    @frame.x = x
    @viewport.rect.x = x + @skin.margin
    @cr_vport.rect.x = x
    @pause_s.x = x + (@width / 2) - 8
    set_arrows
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ y=
  #--------------
  def y=(y)
    @y = y
    @bg.y = y + 2
    @frame.y = y
    @viewport.rect.y = y + @skin.margin
    @cr_vport.rect.y = y
    @pause_s.y = y + @height - @skin.margin
    set_arrows
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ z=
  #--------------
  def z=(z)
    @z = z
    @bg.z = z
    @frame.z = z + 1
    @cr_vport.z = z + 20
    @viewport.z = z + 3
    @pause_s.z = z + 4
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ ox=
  #--------------
  def ox=(ox)
    return if @ox == ox
    @ox = ox
    @viewport.ox = ox
    update_arrows
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ oy=
  #--------------
  def oy=(oy)
    return if @oy == oy
    @oy = oy
    @viewport.oy = oy
    update_arrows
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ width=
  #--------------
  def width=(width)
    @width = width
    @viewport.rect.width = width - @skin.margin * 2
    @cr_vport.rect.width = width
    if @width > 0 and @height > 0
      @frame.bitmap = Bitmap.new(@width, @height)
      @bg.bitmap = Bitmap.new(@width - 4, @height - 4)
      draw_window
    end
    self.x = @x
    self.y = @y
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ height=
  #--------------
  def height=(height)
    @height = height
    @viewport.rect.height = height - @skin.margin * 2
    @cr_vport.rect.height = height
    if @height > 0 and @width > 0
      @frame.bitmap = Bitmap.new(@width, @height)
      @bg.bitmap = Bitmap.new(@width - 4, @height - 4)
      draw_window
    end
    self.x = @x
    self.y = @y
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ opacity=
  #--------------
  def opacity=(opacity)
    value = [[opacity, 255].min, 0].max
    @opacity = value
  #  @contents_opacity = value
    @back_opacity = value
    @frame.opacity = value
    @bg.opacity = value
  #  @window.opacity = value
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ back_opacity=
  #--------------
  def back_opacity=(opacity)
    value = [[opacity, 255].min, 0].max
    @back_opacity = value
    @bg.opacity = value
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ contents_opacity=
  #--------------
  def contents_opacity=(opacity)
    value = [[opacity, 255].min, 0].max
    @contents_opacity = value
    @window.opacity = value
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ cursor_rect
  #--------------
  def cursor_rect
    return @cursor_rect
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ cursor_rect=
  #--------------
  def cursor_rect=(rect)
    @cursor_rect.x = rect.x
    @cursor_rect.y = rect.y
    if @cursor_rect.width != rect.width or @cursor_rect.height != rect.height
      @cursor_rect.set(@cursor_rect.x, @cursor_rect.y, rect.width, rect.height)
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ windowskin
  #--------------
  def windowskin
    return @skin.bitmap
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ windowskin=
  #--------------
  def windowskin=(windowskin)
    return if windowskin == nil
    if @skin.bitmap != windowskin
      @pause_s.bitmap = windowskin
      @pause_s.src_rect = @skin['pause0']
      @skin.bitmap = windowskin
      @cursor_rect.skin = windowskin
      draw_window
      draw_arrows
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ margin=
  #--------------
  def margin=(margin)
    if @skin.margin != margin
      @skin.margin = margin
      self.x = @x
      self.y = @y
      temp = @height
      self.height = 0
      self.width = @width
      self.height = temp
      @cursor_rect.margin = margin
      set_arrows
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ stretch=
  #--------------
  def stretch=(bool)
    if @stretch != bool
      @stretch = bool
      draw_window
    end
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ set_arrows
  #--------------
  def set_arrows
    @arrows[0].x = @width / 2 - 8
    @arrows[0].y = 0#8
    @arrows[1].x = 8
    @arrows[1].y = @height / 2 - 8
    @arrows[2].x = @width - 16
    @arrows[2].y = @height / 2 - 8
    @arrows[3].x = @width / 2 - 8
    @arrows[3].y = @height-7
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ draw_arrows
  #--------------
  def draw_arrows
    return if @skin.bitmap == nil
    @arrows[0].bitmap.blt(0, 0, @skin.bitmap, @skin['arrow_up'])
    @arrows[1].bitmap.blt(0, 0, @skin.bitmap, @skin['arrow_left'])
    @arrows[2].bitmap.blt(0, 0, @skin.bitmap, @skin['arrow_right'])
    @arrows[3].bitmap.blt(0, 0, @skin.bitmap, @skin['arrow_down'])
    update_arrows
  end
  #--------------
  # ÃÂ¢ÃÂÃÂ draw_window
  #--------------
  def draw_window
    return if @skin.bitmap == nil
    return if @width == 0 or @height == 0
    m = @skin.margin
    if @frame.bitmap.nil?
      @frame.bitmap = Bitmap.new(@width, @height)
      @bg.bitmap = Bitmap.new(@width - 4, @height - 4)
    end
    @frame.bitmap.clear
    @bg.bitmap.clear
    if @stretch
      dest_rect = Rect.new(0, 0, @width-4, @height-4)
      @bg.bitmap.stretch_blt(dest_rect, @skin.bitmap, @skin['bg'])
    else
      bgw = Integer((@width-4) / 128) + 1
      bgh = Integer((@height-4) / 128) + 1
      for x in 0..bgw
        for y in 0..bgh
          @bg.bitmap.blt(x * 128, y * 128, @skin.bitmap, @skin['bg'])
        end
      end
    end
    bx = Integer((@width - m*2) / @skin['up'].width) + 1
    by = Integer((@height - m*2) / @skin['left'].height) + 1
    for x in 0..bx
      w = @skin['up'].width
      @frame.bitmap.blt(x * w + m, 0, @skin.bitmap, @skin['up'])
      @frame.bitmap.blt(x * w + m, @height - m, @skin.bitmap, @skin['down'])
    end
    for y in 0..by
      h = @skin['left'].height
      @frame.bitmap.blt(0, y * h + m, @skin.bitmap, @skin['left'])
      @frame.bitmap.blt(@width - m, y * h + m, @skin.bitmap, @skin['right'])
    end
    @frame.bitmap.erase(@width - m, 0, m, m)
    @frame.bitmap.erase(0, @height - m, m, m)
    @frame.bitmap.erase(@width - m, @height - m, m, m)
    @frame.bitmap.blt(0, 0, @skin.bitmap, @skin['ul_corner'])
    @frame.bitmap.blt(@width - m, 0, @skin.bitmap, @skin['ur_corner'])
    @frame.bitmap.blt(0, @height - m, @skin.bitmap, @skin['dl_corner'])
    @frame.bitmap.blt(@width - m, @height - m, @skin.bitmap, @skin['dr_corner'])
  end
end

#==============================================================================
#==============================================================================

#==============================================================================
# Window_Base edit
#==============================================================================
class Window_Base < Window
  
  attr_reader :active_mod_on
  
  #--------------------------------------------------------------------------
  # Draws text on a line. The first line is denoted with 1, not 0.
  #--------------------------------------------------------------------------
  def draw_text(line, string, even_text = false, width = nil)
    return if line <= 0
    y = 32 * line - 32
    if even_text
      if width != nil
        draw_even_text(0, y, width, 32, string)
      else
        draw_even_text(0, y, @width, 32, string)
      end
    else
      self.contents.draw_text(0, y, @width, 32, string)
    end
  end
  #--------------------------------------------------------------------------
  # Draws text on a line, indenting 35 pixels. Can be indented further.
  #--------------------------------------------------------------------------
  def draw_text_indent(line, string, additional=0)
    return if line <= 0
    y = 32 * line - 32
    self.contents.draw_text(35+additional, y, @width, 32, string)
  end
  #--------------------------------------------------------------------------
  # Draws icon on a line. The first line is denoted with 1, not 0.
  #--------------------------------------------------------------------------
  def draw_icon(line, graphic_name)
    return if line <= 0
    y = 32 * line - 32
    bitmap = RPG::Cache.picture(graphic_name)
    rect = Rect.new(0,0,bitmap.width,bitmap.height)
    self.contents.blt(0, y, bitmap, rect)
  end
  #--------------------------------------------------------------------------
  # Draws text and icon with even spacing. The first line is denoted with 1, not 0.
  #--------------------------------------------------------------------------
  def draw_text_icon(line, string, graphic_name)
    return if line <= 0
    draw_icon(line, graphic_name)
    y = 32 * line - 32
    self.contents.draw_text(35, y, @width, 32, string)
  end
  #--------------------------------------------------------------------------
  # Blizzard's even text script modified
  #--------------------------------------------------------------------------
  def draw_even_text(x, y, width, height, text, align = 0)
    new_text = get_even_text(width, text)
    new_text.each_index {|i|
      self.contents.draw_text(x, y + i*height, width, height, new_text[i], align)
    } 
  end
    
  #-----------------------------------------------------------------------------
  # Blizzard's <slice_text> method, modified for Window use only
  # Takes in long string and breaks it up into an array so that each entry does
  # not extend past the specified 'width'.
  #-----------------------------------------------------------------------------
  def get_even_text(width, text)
    width -= 16
    # Replace all instances of \v[n] to the game variable's value
    text.gsub!("\v") {"\\v"}
    text.gsub!("\V") {"\\v"}
    text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
    # Break up the text into lines
    lines = text.split("\n")
    result = []
    # For each line generated from \n
    lines.each{|text_line|
      # Divide text into each individual word
      words = text_line.split(' ')
      current_text = words.shift
      # If there were less than two words in that line, just push the text
      if words.empty?
        result.push(current_text == nil ? "" : current_text)
        next
      end
      # Evaluate each word and determine when text overflows to a new line
      words.each_index {|i|
        if self.contents.text_size("#{current_text} #{words[i]}").width > width
          result.push(current_text)
          current_text = words[i]
        else
          current_text = "#{current_text} #{words[i]}"
        end
        result.push(current_text) if i >= words.size - 1
      }
    }
    return result
  end
  
  #--------------------------------------------------------------------------
  # Return true if mouse is in within the window
  #--------------------------------------------------------------------------
  def mouse_on_window?
    return false unless $mouse.on_screen?
    pos = $mouse.position
    return (pos[0] >= self.x and pos[0] < self.x + self.width and
      pos[1] >= self.y and pos[1] < self.y + self.height)
  end
  
  #--------------------------------------------------------------------------
  # Modify the update method to remove the universal windowskin update
  #--------------------------------------------------------------------------
  def update
    super
    # Process mouse operations if mouse is on screen and custom method implemented
    #if $mouse.on_screen? and @active_mod_on
    #  if mouse_on_window?
    #    Mouse.window_add(self)
    #  end
    #end
  end
  
end

