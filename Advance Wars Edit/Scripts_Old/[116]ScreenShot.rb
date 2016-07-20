#===============================================================================
# Snapshot
# Author game_guy
# Version 1.0
#-------------------------------------------------------------------------------
# Intro:
# Ever wanted to take screenies or snapshots ingame? While there are other
# methods of doing that, this one is by far the easiest. With a simple button
# press or script call, it'll take a screenshot of the game for you and
# save it in a folder.
# Also useful for beta testing. Your testers can snapshot bugs or errors in 
# mapping or stuff like that.
#
# Features:
# Take picture with button press or script call
# Customizable Button to press
#
# Instructions:
# Place screenshot.dll in your projects folder.
# Get the dll here if you need it
# http://decisive-games.com/ggp/scripts/screenshot.dll
# Make a folder in your projects folder called Snapshots
# 
# Go down to the line where it says SnapShot_Key = Input::A
# You can change Input::A to any of the following
# Input::A - Usually the Shift Key
# Input::B - Usually the X or Escape key
# Input::C - Usually C, Enter, or Space
# Input::X - Usually the A Key
# Input::Y - Usually the S Key
# Input::Z - Usually the D Key
# Input::L - Usually the Q Key
# Input::R - Usually the W Key
# Input::SHIFT
# Input::CTRL
# Input::ALT
# Input::F5
# Input::F6
# Input::F7
# Input::F8
# Input::F9
#
# To take a snapshot with a script call use this
# GameGuy.snap thats it!
#
# Compatibility:
# Not tested with SDK. (Should work though)
# Will work with anything.
#
# Credits:
# game_guy ~ For making it
# Google ~ Searching up Win32Api tutorials
# Screenshot.dll ~ Whoever made this, made this script possible
#===============================================================================
module GameGuy
  SnapShot_Key = Input::F5 # Shift Key
  def self.snap
    snp = Win32API.new('screenshot.dll', 'Screenshot', %w(l l l l p l l), '')
    window = Win32API.new('user32', 'FindWindowA', %w(p p), 'l')
    ini = (Win32API.new 'kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 
      'l')
    game_name = "\0" * 256
    ini.call('Game', 'Title', '', game_name, 255, '.\Game.ini')
    game_name.delete!('\0')
    win = window.call('RGSS Player', game_name)
    dir = Dir.new("Snapshots/")
    count = 0
    dir.entries.each {|i| count += 1}
    file_name = "Snapshots/snap_#{count}.png"
    snp.call(0, 0, 640, 480, file_name, win, 2)
  end
end
module Input
  class << self
    alias gg_update_input_snapshot_lat update
  end
  def self.update
    if $DEBUG and Input.trigger?(GameGuy::SnapShot_Key)
      GameGuy.snap
    end
    gg_update_input_snapshot_lat
  end
end