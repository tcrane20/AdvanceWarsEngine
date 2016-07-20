
# SLIGHTLY EDITTED BY KK20
# Original Script: http://forum.chaos-project.com/index.php/topic,4710.0.html

#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# Mouse Controller by Blizzard
# Version: 2.2b
# Type: Custom Input System
# Date: 9.10.2009
# Date v2.0b: 22.7.2010
# Date v2.1b: 8.1.2014
# Date v2.2b: 11.1.2014
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
#   
#  This work is protected by the following license:
# #----------------------------------------------------------------------------
# #  
# #  Creative Commons - Attribution-NonCommercial-ShareAlike 3.0 Unported
# #  ( http://creativecommons.org/licenses/by-nc-sa/3.0/ )
# #  
# #  You are free:
# #  
# #  to Share - to copy, distribute and transmit the work
# #  to Remix - to adapt the work
# #  
# #  Under the following conditions:
# #  
# #  Attribution. You must attribute the work in the manner specified by the
# #  author or licensor (but not in any way that suggests that they endorse you
# #  or your use of the work).
# #  
# #  Noncommercial. You may not use this work for commercial purposes.
# #  
# #  Share alike. If you alter, transform, or build upon this work, you may
# #  distribute the resulting work only under the same or similar license to
# #  this one.
# #  
# #  - For any reuse or distribution, you must make clear to others the license
# #    terms of this work. The best way to do this is with a link to this web
# #    page.
# #  
# #  - Any of the above conditions can be waived if you get permission from the
# #    copyright holder.
# #  
# #  - Nothing in this license impairs or restricts the author's moral rights.
# #  
# #----------------------------------------------------------------------------
# 
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
# 
# Compatibility:
# 
#   90% compatible with SDK v1.x. 80% compatible with SDK v2.x. May cause
#   incompatibility issues with other custom input Systems. Works with "Custom
#   Game Controls" from Tons of Add-ons and Blizz-ABS's custom controls.
#   This script is not meant to be used as a standalone but rather in
#   combination with special menus that are properly adapted to support a mouse
#   controller system.
#   
#   
# Features:
# 
#   - fully automated mouse control in game
#   - can be enhanced with "Custom Game Controls" from Tons of Add-ons
#   - can be enhanced with "Blizz-ABS Controls"
#   - can be enhanced with "RMX-OS"
# 
# new in 2.0b:
# 
#   - added option to hide Windows' cursor
#   - added possibility to hide and show the ingame cursor during the game
#   - added possibility to change the cursor icon
#   - added several new options
#   - optimized
# 
# new in 2.1b:
# 
#   - added support for .cur and .ani cursor files instead of sprites
#   - changed code to use system cursor rather than a sprite to greatly
#     increase performance
# 
# new in 2.2b:
# 
#   - removed hardware cursor support due to problems with display in
#     fullscreen (which cannot be fixed)
#   - added option to specify a custom game name if Game.ini is not present
# 
# 
# Instructions:
# 
# - Explanation:
# 
#   This script can work as a stand-alone for window option selections. To be
#   able to use the mouse buttons, you need a custom Input module. The
#   supported systems are "Custom Game Controls" from Tons of Add-ons,
#   Blizz-ABS Custom Controls and RMX-OS Custom Controls. This script will
#   automatically detect and apply the custom input modules' configuration
#   which is optional.
#   
# - Configuration:
# 
#   MOUSE_ICON          - the default filename of the icon located in the
#                         Graphics/Pictures folder
#   APPLY_BORDERS       - defines whether the ingame cursor can go beyond the
#                         game window borders
#   WINDOW_WIDTH        - defines the window width, required only when using
#                         APPLY_BORDER
#   WINDOW_HEIGHT       - defines the window height, required only when using
#                         APPLY_BORDER
#   HIDE_WINDOWS_CURSOR - hides the Windows Cursor on the window by default
#   AUTO_CONFIGURE      - when using "Custom Game Controls" from Tons of
#                         Add-ons, Blizz-ABS or RMX-OS, this option will
#                         automatically add the left mouse button as
#                         confirmation button
#   CUSTOM_GAME_NAME    - specify a custom game name here if Game.ini is not
#                         present (simply use the name from the original
#                         Game.ini)
#   
# - Script Calls:
#   
#   You can use a few script calls to manipulate the cursor. Keep in mind that
#   these changes are not being saved with the save file.
#   
#   To hide the ingame Mouse Cursor, use following call.
#   
#     $mouse.hide
#   
#   To show the ingame Mouse Cursor, use following call.
#   
#     $mouse.show
#   
#   To change the cursor image, use following call. Make sure your image is in
#   the Graphics/Pictures folder.
#   
#     $mouse.set_cursor('IMAGE_NAME')
#   
#   
# Additional Information:
#   
#   Even though there is an API call to determine the size of the window, API
#   calls are CPU expensive so the values for the window size need to be
#   configured manually in this script.
#   
# 
# If you find any bugs, please report them here:
# http://forum.chaos-project.com
#:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

$mouse_controller = 2.2

#===============================================================================
# Mouse
#===============================================================================

class Mouse
  
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# START Configuration
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  MOUSE_ICON = ''
  APPLY_BORDERS = true
  WINDOW_WIDTH = 640
  WINDOW_HEIGHT = 480
  HIDE_WINDOWS_CURSOR = false
  CUSTOM_GAME_NAME = ''
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# END Configuration
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  
  if HIDE_WINDOWS_CURSOR
    Win32API.new('user32', 'ShowCursor', 'i', 'i').call(0)
  end
  
  SCREEN_TO_CLIENT = Win32API.new('user32', 'ScreenToClient', %w(l p), 'i')
  READ_INI = Win32API.new('kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 'l')
  FIND_WINDOW = Win32API.new('user32', 'FindWindowA', %w(p p), 'l')
  CURSOR_POSITION = Win32API.new('user32', 'GetCursorPos', 'p', 'i')
  
  def initialize
    @cursor = Sprite.new
    @cursor.z = 1000000
    self.set_cursor(MOUSE_ICON)
    update
  end
  
  def update
    @cursor.x, @cursor.y = self.position
  end
  
  def x
    return @cursor.x
  end
  
  def y
    return @cursor.y
  end
  
  def position
    x, y = self.get_client_position
    if APPLY_BORDERS
      if x < 0 || x >= WINDOW_WIDTH || y < 0 || y >= WINDOW_HEIGHT
        x, y = -1, -1
      end
    end
    return x, y
  end
  
  def get_client_position
    pos = [0, 0].pack('ll')
    CURSOR_POSITION.call(pos)
    SCREEN_TO_CLIENT.call(WINDOW, pos)
    return pos.unpack('ll')
  end
  
  def set_cursor(filename)
    @cursor.bitmap = RPG::Cache.picture(filename) rescue nil
  end
  
  def show
    @cursor.visible = true
  end
  
  def hide
    @cursor.visible = false
  end
  
  def on_screen?
    return self.position != [-1, -1]
  end
  
  
  def self.find_window
    if CUSTOM_GAME_NAME == ''
      game_name = "\0" * 256
      READ_INI.call('Game', 'Title', '', game_name, 255, '.\\Game.ini')
      game_name.delete!("\0")
    else
      game_name = CUSTOM_GAME_NAME
    end
    return FIND_WINDOW.call('RGSS Player', game_name)
  end
  
  WINDOW = self.find_window
  
end

$mouse = Mouse.new

#==============================================================================
# module Input
#==============================================================================

module Input
  
  class << Input
    alias update_mousecontroller_later update
  end
  
  def self.update
    $mouse.update
    update_mousecontroller_later
  end
  
end


#===============================================================================
# Rect
#===============================================================================

class Rect
  
  def covers?(x, y)
    return !(x < self.x || x >= self.x + self.width ||
        y < self.y || y >= self.y + self.height)
  end
  
end

#===============================================================================
# Sprite
#===============================================================================

class Sprite
  
  def mouse_in_area?
    return false if self.bitmap == nil
    return ($mouse.x >= self.x && $mouse.x < self.x + self.src_rect.width &&
        $mouse.y >= self.y && $mouse.y < self.y + self.src_rect.height)
  end
  
end

#===============================================================================
# Window_Base
#===============================================================================

class Window_Base
  
  def mouse_in_area?
    return ($mouse.x >= self.x && $mouse.x < self.x + self.width &&
        $mouse.y >= self.y && $mouse.y < self.y + self.height)
  end
  
  def mouse_in_inner_area?
    a = ($mouse.x >= self.x + 5 && $mouse.x < self.x + self.width - 5 &&
        $mouse.y >= self.y + 5 && $mouse.y < self.y + self.height - 5)
    return a
  end
  
end

#===============================================================================
# Window_Selectable
#===============================================================================

class Window_Selectable
  
  alias contents_is_mousecontroller_later contents=
  def contents=(bitmap)
    contents_is_mousecontroller_later(bitmap)
    begin
      update_selections
      update_mouse if self.active
    rescue
    end
  end
  
  alias index_is_mousecontroller_later index=
  def index=(value)
    index_is_mousecontroller_later(value)
    update_selections
  end
  
  alias active_is_mousecontroller_later active=
  def active=(value)
    active_is_mousecontroller_later(value)
    update_cursor_rect
  end
  
  def update_selections
    @selections = []
    index, ox, oy = self.index, self.ox, self.oy
    (0...@item_max).each {|i|
        @index = i
        update_cursor_rect
        rect = self.cursor_rect.clone
        rect.x += self.ox
        rect.y += self.oy
        rect.height = 32
        @selections.push(rect)}
    @index, self.ox, self.oy = index, ox, oy
    self.cursor_rect.empty
  end
  
  alias update_mousecontroller_later update
  def update
    update_mouse if self.active
    update_mousecontroller_later
  end
  
  def update_mouse
    if self.contents != nil && @selections.size > 0 && self.mouse_in_area? && !self.mouse_in_inner_area?
      update_mouse_scrolling
    else
      update_mouse_selection
    end
  end
  
  def update_mouse_selection
    update_selections if @selections.size != @item_max
    return unless self.mouse_in_inner_area?
    @selections.each_index {|i|
        if @selections[i].covers?($mouse.x - self.x - 5 + self.ox,
            $mouse.y - self.y - 5 + self.oy)
          self.index = i if self.index != i
          return
        end}
    #self.index = -1
  end
  
  def update_mouse_scrolling
    if Input.repeat?(Input::Key['Mouse Left'])
      #if $mouse.x < self.x + 5
      #  if self.ox > 0
      #    $game_system.se_play($data_system.cursor_se)
      #    self.ox -= @selections[0].width
      #    self.ox = 0 if self.ox < 0
      #  end
      #elsif $mouse.x >= self.x + self.width - 5
      #  max_ox = self.contents.width - self.width + 32
      #  if self.ox <= max_ox
      #    $game_system.se_play($data_system.cursor_se)
      #    self.ox += @selections[0].width
      #    self.ox = max_ox if self.ox >= max_ox
      #  end
      if $mouse.y < self.y + 5
        if self.oy > 0
          $game_system.se_play($data_system.cursor_se)
          self.oy -= @selections[0].height
          self.oy = 0 if self.oy < 0
        end
      elsif $mouse.y >= self.y + self.height - 5
        max_oy = self.contents.height - self.height + 8
        if self.oy < max_oy
          $game_system.se_play($data_system.cursor_se)
          self.oy += @selections[0].height
          self.oy = max_oy if self.oy >= max_oy
        end
      end
    end
  end
  
end