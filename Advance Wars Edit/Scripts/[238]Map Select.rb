=begin
_________________________
 Window_MapSelect        \______________________________________________________
 
 Window for Scene_MainMenu. Draws all map names in a column. Requests for
 minimap sprites and also appears to initialize maps with configuration data in
 them (that should be done elsewhere now that I think about it, like on loadup).
 
 Notes:
 * Map initialization should be handled outside of this class, preferably when
 game is loading upon opening.
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Window_MapSelect < Window_Selectable
	
	def initialize(index = 0)
		super(40,50,180,8+12*32)
		self.active = true
		self.index = index
		@old_index = 0
    @minimap_viewport = Viewport.new(0,0,640,480)
    @minimap_viewport.z = 10000
		refresh
	end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
		@mapfiles = []
    @map_players = []
		# Load map names into list
		infos = load_data("Data/MapInfos.rxdata")
    # Check each map file
		Dir.foreach("Data/") do |filename|
      # If filename contains the basic 'Map00x' format
			if filename =~ /Map[\d]+\.rxdata/
        # Map ID and load it
				num = filename[/\d+/].to_i
        map = load_data(sprintf("Data/Map%03d.rxdata", num))
        if map.initialized?
          # Push map into list with its name
          @data.push(infos[num].name)
          @mapfiles.push(num)
          next
        end
        # Loop through the map's events
        for i in map.events.keys
          # Looking for an event at (0,0)
          next unless (map.events[i].x == 0 and map.events[i].y == 0)
          # If first command in event list is a comment-line
          if [108].include?(map.events[i].pages[0].list[0].code) and
            map.events[i].pages[0].list[0].parameters[0] == "MapConfig"
            # Interprets the special comment command
            code_index = 0
            map.events[i].pages[0].list.each{|type| 
            type.parameters.each{|content|
            # content is a string
              case code_index
              when 1
                eval("map.army_setup = #{content}")
              when 2
                eval("map.team_lose = #{content}")
              when 3
                eval("map.lose_conditions = #{content}")
              when 4
                eval("map.army_colors = #{content}")
              end
              code_index+=1
            }
            }
            # Save map file with configurations
            mapfile = File.open(sprintf("Data/Map%03d.rxdata", num), "wb")
            Marshal.dump(map, mapfile)
            mapfile.close
            # Push map into list with its name
            @data.push(infos[num].name)
            @mapfiles.push(num)
          end
          break # Found our event, stop looping
        end
        # Failed to find a map initializer event. Do not load into list.
			end
		end 
    # If item count is not 0, make a bit map and draw all items
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
		get_minimap
  end	
	
	def draw_item(index)
		draw_text(index+1, @data[index])
	end
	
	def get_map
		map_id = @mapfiles[@index]
		#@minimap.visible = false
		return map_id
	end
	
	def dispose
		@minimap.dispose
		super
	end
	
	def visible=(bool)
		@minimap.visible = bool
		super(bool)
	end
	
	def get_minimap
		@old_index = @index
		@minimap.dispose unless @minimap.nil?
		map = load_data(sprintf("Data/Map%03d.rxdata", @mapfiles[@index]))
		@minimap = Minimap_Graphic.new(map, @minimap_viewport)
    # Testing by adding variables to RPG::Map
    #map.players_setup = [] #KK20
   # mapfile = File.open(sprintf("Data/Map%03d.rxdata", @mapfiles[@index]), "wb")
   # Marshal.dump(map, mapfile)
   # mapfile.close
	end
	
	alias get_minimap_before_update update
	def update
		get_minimap if @index != @old_index
		get_minimap_before_update
	end
	
end
