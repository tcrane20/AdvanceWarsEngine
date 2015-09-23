=begin

Things I noticed:
  -Cursor is not invisible at appropriate times
  -CO Profiles scene not done (will error)
  -Flag sprites have high z-values; they overlap sprites that should be higher
  -Crashing units error the game (their flag sprites are updated when already disposed)
  -Mouse click needs button assignment to it at appropriate times. Can't scroll
  down a window without triggering to select the item if left click = C.
  

Thing I know I have finished
    * Improved CO bars (they flash and bounce--pretty!)
    * Sliding CO tag and info window; watch them accelerate on and off screen
    * Cleaned up a few existing things that really needed it
    * New methods regarding drawing ranges and calculating them (faster)
    * Bug fixes
      - Crashing units (fuel = 0) no longer cause weird errors
      - Units with specialized can_attack methods are fixed and make more sense
    * 3 player maps work. Haven't tried 4 players yet.
    * Tied with above, maps now have a configuration thingie at the top corner
    * Tilemap rewrite script works with this project
    * Started working on CO Power animations
    * Almost done ripping tileset sprites
    
    
    
    
=end    

  