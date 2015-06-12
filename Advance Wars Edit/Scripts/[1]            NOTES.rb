=begin

  ! Joining two units in FOW causes an error to occur
  - Message box
  - rework Window rewrite





  - Define what the map properties are. Need to know how many players, what are
    the special conditions, and win-lose conditions.
    Best way is to save the variable to the map file. How? Maybe by use of an
    event with a comment code in it. Run the game once and it will create a new
    map file with the properites saved in it.
  - Saving maps, accessing them, and distributing them.
    First off, map names must be saved in the file somehow. For ease, perhaps
    name the map file the map's name. Maps will be saved in a separate folder
    for ease of access. The only problem that can arise is loading maps into
    the RMXP program. Something of this measure is most likely not serious
    unless the player wants to make some drastic changes to the map. The game
    will already come packed with a level editor that can access these maps
    not following the 'Mapxxx' file name.
  - Loading maps into the map select screen.
    The tricky part is being able to distinguish what type of maps these are
    (War Room, Campaign, 2P, Classic, etc.). Maybe when the player configures
    the map in the RMXP program via use of event, it can save that variable too.
    Most likely maps made with the ingame editor will be thrown into Custom.
    As such, for all the other maps, it should probably be noted that the map
    properties must be included.
  - What are the map properties?
    * Players
      Array designating which army is what player.
      Ex. [2,0,1,3,4] -> Green Earth is 1P, OS is 2P, YC is 3P, BH is 4P
    * Lose conditions
      Basic conditions of losing.
      Ex. [0, 1, 2, 3, 0] -> OS and BH lose if routed or HQ capt.
                             BM loses if HQ capt, but not routed.
                             GE loses if routed, but not HQ capt.
                             YC cannot lose even if routed or HQ capt.
    * Team Lose Conditions
      Lose based on teammate's performance.
      Ex. [2,1,1,0,0] -> BM and GE will lose if their teammate loses. OS is
                         assigned as leader. If OS+BM+GE on team, the following:
                         OS loses -> BM and GE lose
                         BM loses -> OS and GE are fine
                         GE loses -> OS and BM are fine
                         If BM+GE on team, the following:
                         BM loses <-> GE loses
                         If BM+GE+YC on team, the following:
                         BM loses <-> GE loses
                         YC loses -> BM and GE lose
                         (The value of '2' is only necessary in 3 man teams)
    * Army Colors
      Follow army colors based on selected army. True/False condition.
      Ex. Assume the following players: [2,0,1,3,4]
      If TRUE, then GE is Green, OS is red, YC is yellow, BH is black
      If FALSE, then GE is red, OS is blue, YC is green, BH is yellow
      (Best suited for War Room and Campaign maps)
  - So how are these going to be saved?
    @players_setup = 
    @lose_conditions =
    @team_lose = 
    @army_colors =
    def num_of_players # take @players_setup and count non-zeros
      



















=end