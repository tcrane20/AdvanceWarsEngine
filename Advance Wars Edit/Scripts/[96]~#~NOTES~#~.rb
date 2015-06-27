=begin

<> something = File.open("name.rxdata", "wb") creates the file "name" if "name"
   doesn't exist. Otherwise, it will open the existing file. Because of "wb",
   when we store values in it via Marshal.dump, it will overwrite it. It is
   necessary to use something.close when done.
   Therefore, for map editting, we can create a window saying which file the user
   will load. Then, set $game_map.map to equal the file's contents. Saving will
   store it back to that file.
   This can be useful for saving games as well.

<!> Windows must be of height 40 + 32n. Text is drawn at X = 5 and Y = 8 + 32n.
    If using a window's contents/bitmap, text is drawn at [0, 3n], assuming the
    bitmap is (@width, @height).
      
<> Use the following to check the names of all files located in the directory:
    Dir.foreach("Data/") do |entry|
      p (entry)
    end
      
<> We can create another folder that holds Maps. The game, upon loading, can put
    these map files into the /Data folder by using appropriate ID values. That
    way the map can now be editted by the user. Perhaps create a way to prevent edits?

<> You can edit the map's dimensions via $game_map.map.width/height, however you
    need to edit the @map.data to accomodate the change.

< Formulas >

  [[ Damage ]]
  (Base Damage * (0.1 * HP) * Attack Boost + Luck) / (Defense / 100)
  
  [[ Terrain ]]
  1 Star = 10 * Unit HP 
  
  [[ Luck ]]
  Everyone has a base luck of 5. That means damage can range from X ... X+5.
  Luck Bonus = rand(0~5) * (0.1 * Unit HP)
  
  [[ Powers ]]
  Every CO gets a +10 defense boost for units not mentioned in the CO Profiles.
  
  [[ S. Powers ]]
  Every CO gets a +20 defense boost for units not mentioned in the CO Profiles.
________________________________________________________________________________
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
    W H O   T H E   H E L L   D O   I   C R E D I T   F O R   T H I S ? ? ?
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
-> Blizzard:
      * Multiple Inputs Script
      * Writing errors to text files
-> Game_Guy:
      * Manipulating events syntax
      * Screenshot script
-> ForeverZer0:
      * Advanced Weather script
      * Debugging tool
-> GubiD:
      * GTBS (scripts were referenced and/or editted to fit)
-> Selwyn:
      * Window Class rewrite
-> Legacy:
      * High Priority script
-> Cogwheel (and GubiD):
      * Audio MP3 Loop script
-> DerVVulfman:
      * Mouse Input script
-> Nintendo/Intelligent Systems:
      * For the media and game idea. All copyright to them.
-> :
      * 
=end