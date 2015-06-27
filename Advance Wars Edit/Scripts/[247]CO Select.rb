=begin
__________________
 CO_Select        \_____________________________________________________________
 
 Pretty complicated thing I made here. It's a sprite that can process player 
 input to do things like as if a scene. This class handles everything regarding
 to choosing which CO the player(s) wish to be, both in the "These are the
 COs you selected. Are you ready?" and "Here's a list of COs to play as".
 
 Notes:
 * This is highly questionable programming. I really should make this a scene
 and not a sprite.
 * Still missing features like CO names, button indicators, player/CPU, teams
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class CO_Select < RPG::Sprite
  attr_reader :tab_index, :index, :selected_CO, :player_COs, :go_back
  
  alias init_sprite initialize
  # players = array of size 5, holds int values 0-5
  def initialize(currentCOs = nil, army_setup = [1,2,0,0,0])
    init_sprite
    self.bitmap = Bitmap.new(640, 480)
    # Setup variables
    count = 0
    armies = []
    army_setup.each_index{|i|
      a = army_setup[i]
      # If player turn for selected army
      if a != 0
        count += 1 
        # Player 'a' is in control of army 'i'
        armies[a] = i
      end
    }
    armies.delete(nil)
    players = count 
    
    @numof_players = players
    @phase = 0
    @player_index = 0
    @index = 0
    @tab_index = 0
    # Load array of player CO choices
    @player_COs = (currentCOs.nil? ? [CO_Andy.new(Army.new(0,0)), CO_Olaf.new(Army.new(0,0)), CO_Eagle.new(Army.new(0,0)), CO_Kanbei.new(Army.new(0,0)), CO_Flak.new(Army.new(0,0))] : currentCOs)
    # Initialize sprite for drawing on
    @sprite_player_COs = Sprite.new
    @sprite_player_COs.bitmap = Bitmap.new(640,480)
    # Sets spacing of profiles
    @spacing = [50,25,24].delete_at(players-2)
    @first_draw_x = (640-(111*players)-(@spacing*(players-1)))/2
    # Load graphics
    @graphics = RPG::Cache.picture("coselect_graphics")
    # Draw the CO faces and borders
    armies.each_index{|i|
      # Border (Chooses color that matches army)
      rect = Rect.new(284+(111*(armies[i])),0,111,111)
      @sprite_player_COs.bitmap.blt(@first_draw_x+(i*(@spacing+111)),200, @graphics, rect)
      # CO face
      co = @player_COs[armies[i]]
      spritesheet = RPG::Cache.picture("CO_" + co.name)
      rect = Rect.new(0, 700, 96, 96)
      @sprite_player_COs.bitmap.blt(7+@first_draw_x+(i*(@spacing+111)),207,spritesheet,rect)
    }
    #Draw cursor
    @cursor = Sprite.new
    @cursor.bitmap = Bitmap.new(76,44)
    @cursor.bitmap.blt(0,0,@graphics,Rect.new(140,104,76,44))
    @cursor.x, @cursor.y = @first_draw_x+17, 319
    # Make the CO info window
    @co_info_window = Window_Base.new(340, 312, 300, 168)
    @co_info_window.contents = Bitmap.new(300,168)
    @co_info_window.visible = false
  end
  
  def index=(amt)
    @index = amt % @co_list.size
    change_tabs
  end
  
  def tab_index=(amt)
    @tab_index = amt % 5
    change_tabs
  end
  
  def update
    super
    case @phase
      #==============================================
    when 0 # See what COs the players have chosen
      if Input.trigger?(Input::Key['Enter'])
        Config.play_se("decide")
        $scene = Scene_AWMap.new
      elsif Input.trigger?(Input::C)
        # Change CO screen
        Config.play_se("decide")
        @phase = 1
        @co_info_window.visible = true
        case @player_COs[@player_index].nation
        when "Blue Moon" then @tab_index = 1
        when "Green Earth" then @tab_index = 2
        when "Yellow Comet" then @tab_index = 3
        when "Black Hole" then @tab_index = 4
        else
          @tab_index = 0
        end
        @sprite_player_COs.visible = false
        @cursor.visible = false
        change_tabs(true)
      elsif Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        # Return to map select
        @go_back = true
        dispose
      elsif Input.repeat?(Input::LEFT)
        return if @player_index == 0
        $game_system.se_play($data_system.cursor_se)
        @cursor.x -= @spacing+111
        @player_index -= 1
      elsif Input.repeat?(Input::RIGHT)
        return if @player_index == @numof_players - 1
        $game_system.se_play($data_system.cursor_se)
        @cursor.x += @spacing+111
        @player_index += 1
      end
      #==============================================
    when 1 # Choosing which CO to be
      if Input.trigger?(Input::C)
        Config.play_se("decide")
        # Save this CO and put it as player's CO of choice
        @player_COs[@player_index] = @selected_CO
        # Update player CO profiles
        spritesheet = RPG::Cache.picture("CO_" + @selected_CO.name)
        rect = Rect.new(0, 700, 96, 96)
        @sprite_player_COs.bitmap.fill_rect(7+@first_draw_x+(@player_index*(@spacing+111)),207,96,96,Color.new(0,0,0,0))
        @sprite_player_COs.bitmap.blt(7+@first_draw_x+(@player_index*(@spacing+111)),207,spritesheet,rect)
        # Return to player selection
        self.bitmap.clear
        @sprite_player_COs.visible = true
        @cursor.visible = true
        @phase = 0
        @co_info_window.visible = false
      elsif Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        # Return to seeing players' choices
        @sprite_player_COs.visible = true
        @cursor.visible = true
        @phase = 0
        @co_info_window.visible = false
        self.bitmap.clear
      elsif Input.trigger?(Input::R)
        Config.play_se("pageturn")
        self.tab_index += 1
      elsif Input.trigger?(Input::L)
        Config.play_se("pageturn")
        self.tab_index -= 1
      elsif Input.trigger?(Input::A)
        Config.play_se("decide")
        # CO Bio window
        @phase = 2
        @co_info_window.visible = false
        @bio_window = OfficerBio_Window.new(@selected_CO)
      elsif Input.dir4 != 0
        if Input.repeat?(Input::DOWN)
          return if @index+3 >= @co_list.size
          $game_system.se_play($data_system.cursor_se)
          self.index = @index+3
        elsif Input.repeat?(Input::LEFT)
          $game_system.se_play($data_system.cursor_se)
          self.index = @index - 1
        elsif Input.repeat?(Input::RIGHT)
          $game_system.se_play($data_system.cursor_se)
          self.index = @index + 1
        elsif Input.repeat?(Input::UP)
          return if @index-3 < 0
          $game_system.se_play($data_system.cursor_se)
          self.index = @index-3
        end
      end
      #==============================================
    when 2 # Officer Bio window
      @bio_window.update
      if @bio_window.delete
        @phase = 1
        @co_info_window.visible = true
      end
    end
    
  end
  
  def change_tabs(first_time = false)
    @index = -1 if first_time
    # Black Hole tab
    rect = Rect.new(0,0,76,34)
    self.bitmap.blt(264,4,@graphics,rect)
    # Yellow Comet tab
    rect = Rect.new(0,34,76,34)
    self.bitmap.blt(196,4,@graphics,rect)
    # Green Earth tab
    rect = Rect.new(0,68,76,34)
    self.bitmap.blt(128,4,@graphics,rect)
    # Blue Moon tab
    rect = Rect.new(0,102,76,34)
    self.bitmap.blt(60,4,@graphics,rect)
    # Orange Star tab
    rect = Rect.new(0,136,76,34)
    self.bitmap.blt(-8,4,@graphics,rect)
    # Window
    self.bitmap.fill_rect(Rect.new(0,36,340,444), @graphics.get_pixel(10,136-34*@tab_index))
    self.bitmap.fill_rect(Rect.new(1,37,338,442), @graphics.get_pixel(10,136-34*@tab_index))
    self.bitmap.fill_rect(Rect.new(2,38,336,440), @graphics.get_pixel(10,138-34*@tab_index))
    # Nation tag
    rect = Rect.new(0,136-34*@tab_index,76,34)
    self.bitmap.blt(-8+68*@tab_index,4,@graphics,rect)
    # Setup which army officers to display
    @co_list = []
    case @tab_index
    when 0 then $CO.each{|co| @co_list.push(co) if co.nation == "Orange Star" }
    when 1 then $CO.each{|co| @co_list.push(co) if co.nation == "Blue Moon" }
    when 2 then $CO.each{|co| @co_list.push(co) if co.nation == "Green Earth" }
    when 3 then $CO.each{|co| @co_list.push(co) if co.nation == "Yellow Comet" }
    when 4 then $CO.each{|co| @co_list.push(co) if co.nation == "Black Hole" }
    end
    @index = @co_list.size-1 if @index >= @co_list.size
    # CO Select Windows
    [0,1,2,3].each{|y| [0,1,2].each{|x| 
        self.bitmap.blt(7 + x*111, 44 + y*109, @graphics, Rect.new(76,0,104,104))
        
      } }
    
    # Draw CO faces
    index = 0
    @co_list.each{|co|
      @index = index if (first_time and co.name == @player_COs[@player_index].name)
      spritesheet = RPG::Cache.picture("CO_" + co.name)
      draw_selected_CO(co, spritesheet) if (@index == index or (first_time and co == @player_COs[@player_index]))
      rect = Rect.new(0, 700, 96, 96)
      self.bitmap.blt(11+(index%3)*111,48+(index/3)*109,spritesheet,rect)
      index += 1
    }
  end
  
  def draw_selected_CO(officer, graphics)
    self.bitmap.fill_rect(340, 0, 300, 480, Color.new(0,0,0,0))
    # Draw CO
    rect = Rect.new(0,0,288,700)
    self.bitmap.blt(400,0,graphics,rect)
    # Draw CO info window
    @co_info_window.contents.clear
    @co_info_window.draw_text(1, officer.description[7], true)
    @selected_CO = officer
    # Darkened profile background for selected CO
    self.bitmap.fill_rect(Rect.new(11+111*(@index%3),48+109*(@index/3),96,96), @graphics.get_pixel(10,136-34*@tab_index))
    self.bitmap.blt(7 + (@index%3)*111, 44 + (@index/3)*109, @graphics, Rect.new(180,0,104,104))
  end
  
  def dispose
    @co_info_window.dispose
    @sprite_player_COs.dispose
    @cursor.dispose
    super
  end
  
end
