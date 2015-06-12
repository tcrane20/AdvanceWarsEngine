=begin
______________________
 Spriteset_Map        \_________________________________________________________
 
 Handles all, or most, of the graphics drawn onto the map. Modified RPG Maker
 class, so it's very messy at the moment. I know this class instance is stored
 in $spriteset global variable. I'll need to think about how I can make this
 as simplistic as possible.
 
 Unit sprites should be able to call #sprite and get the sprite in this class.
 Makes things easier to program in the long run.
 
 Notes:
 * Clean up mandatory
 * Needs to handle unit sprites, not the Unit class itself
 
 Updates:
 - ll/30/14
   + Removed unneeded viewports. Hoping to somehow pass data about what type of
     tile to draw in the Tilemap.
 - 11/08/14
   + Tried using a second Tilemap to act as the ranges. Using methods to change
     the tilemap layer's colors is time consuming, dropping FPS to low amounts.
________________________________________________________________________________
=end
class Spriteset_Map
	attr_reader :unit_sprites, :viewport1, :viewport2, :viewport3, :tilemap, :fow_tilemap, :finished_destruction
  attr_accessor :unit_moving, :player_sprite
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
  alias init_for_other_graphics initialize
	def initialize
    # A table that stores information about what type of tile to draw at [x,y]
    # for the Tilemap. For example, a 0 indicates a normal tile while a 1 is a
    # tile that is animating to represent a unit's move or attack range.
    @tiletype_table = Array2D.new($game_map.width, $game_map.height, 0)
		# Info Window graphic
		@info_window = StatWindow.new
		# Set up officer tag
		@officer_tag = nil
		# If a unit graphic is moving, this is set to true
		@unit_moving = false
    # Array of all unit sprites
    @unit_sprites = []
    # Alias
    @first_update = true
    init_for_other_graphics
    @first_update = false
    # Delete last character sprite
    @character_sprites.pop
    # Move player (cursor) sprite to higher viewport
    @player_sprite = Sprite_Character.new(@viewport2, $game_player)
    
    @day_animation = Day_Animation.new
	end
	#--------------------------------------------------------------------------
	# Draws the unit sprites upon initialize of the game
	#--------------------------------------------------------------------------
	def init_units
		for unit in $game_map.units
			# Initialize the unit's sprite
			unit.sprite_id = @unit_sprites.size
      @unit_sprites.push(Unit_Sprite.new(@viewport1, unit))
		end
	end
	#--------------------------------------------------------------------------
	# Draws the unit into the map spriteset. Also assigns the Unit object an
  # ID number to reference its Sprite object.
	#--------------------------------------------------------------------------
	def draw_unit(unit)                #kk20 1
    # Locate an open spot in the array
    id = @unit_sprites.index(nil)
    # If none, add to the end of the array
    if id.nil?
      unit.sprite_id = @unit_sprites.size
      @unit_sprites.push(Unit_Sprite.new(@viewport1, unit))
    else
      unit.sprite_id = id
      @unit_sprites[id] = Unit_Sprite.new(@viewport1, unit)
    end
	end
	#--------------------------------------------------------------------------
	# Draws the officer tag for the current player's army
	#--------------------------------------------------------------------------
	def draw_officer_tag(army = nil)
		@officer_tag.dispose unless @officer_tag.nil?
		return if army == nil
		@officer_tag = Officer_Tag_Graphic.new(@viewport2, army)
	end
	#--------------------------------------------------------------------------
	# * Dispose
	#--------------------------------------------------------------------------
  alias dispose_units_and_cursor dispose
	def dispose
    dispose_units_and_cursor
    @unit_sprites.each{|s| next if s.nil? ; s.dispose}
		@player_sprite.dispose
	end
	
	#-------------------------------------------------------------------------
	# Reverts the color and acted of units
	#-------------------------------------------------------------------------
	def revert_unit_colors
		$game_map.units.each{|u|
			next if @unit_sprites[u.sprite_id].disposed?
			@unit_sprites[u.sprite_id].color.set(0, 0, 0, 0)
			u.acted = false
		}
	end
	
  #-------------------------------------------------------------------------
	# Color blend a tilemap when showing ranges
	#-------------------------------------------------------------------------
  def show_ranges(data)
    if data
      data.each{|tile| @tiletype_table[tile.x, tile.y] = 1}
    else
      @tiletype_table = Array2D.new($game_map.width, $game_map.height, 0)
    end
  end
  #-------------------------------------------------------------------------
	# Assigns a sprite to currently look at for receiving "animation_end"
  # triggers. Used in conjunction with Cursor#add_move_action.
	#-------------------------------------------------------------------------
  def watch_for_animation_end(sprite)
    @watch_sprite_animation = sprite
  end
  #-------------------------------------------------------------------------
	# Returns TRUE if the sprite has finished playing its animation.
	#-------------------------------------------------------------------------
  def animation_end?
    return false if @watch_sprite_animation.nil?
    return @watch_sprite_animation.animation_end?
  end
  
  
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
  alias update_smap_aw update
	def update
    update_smap_aw
    return if @first_update
    # This flag is needed to tell the Scene_Map that the unit has finished playing
    # its destruction animation. Resets to false every frame.
    @finished_destruction = false
		# Update unit animations
		# Update unit sprite graphics
		for unit in $game_map.units
      next if unit.nil? || unit.sprite_id.nil?
      sprite = @unit_sprites[unit.sprite_id]
			sprite.update unless (sprite.nil? or sprite.disposed?) #.nil? KK20
			# If unit needs to be removed from the map
			if unit.needs_deletion
				# If unit is removed due to loss in battle and not by joining
				if unit.destroyed
          unit.destroyed = false
          # Make a dummy bitmap so that an animation can be played
					sprite.bitmap = nil
          sprite.dispose_flags
					sprite.play_animation('destroy')
				end
        # The destruction animation has finished
				if sprite.animation_end?
          @finished_destruction = true
          # Dispose remaining flags
					sprite.dispose
          @unit_sprites[unit.sprite_id] = nil
					index = unit.army.units.index(unit)
          unit.army.units[index] = nil
				end
			end
		end
    # Actually update the tilemap
		@tilemap.update(@tiletype_table.flatten.compact)
    # Update the cursor sprite
    @player_sprite.update
    @player_sprite.visible = $game_player.visible
    # Update officer tag
    @officer_tag.update unless @officer_tag.nil?
    # Update info window (gray rectangle at bottom corners)
    @info_window.update
		# Update viewport
    #@viewport2.update
    if Input.trigger?(Input::Key['9']) #kk20
      @day_animation.animate
    elsif Input.trigger?(Input::C)
      @day_animation.stop
    end
    @day_animation.update
	end
	
	# Updates the vision for the player
	def update_fow
		return unless $game_map.fow
		@fow_tilemap.map_data = @fow_tilemap.map_data.clone
		# Expose owned props
		$scene.player.owned_props.each{|prop|
			# Check 1 tile around the property
			$game_map.get_spaces_in_area(prop.x, prop.y, prop.vision).each{|pos|
				x,y = pos[0],pos[1]
				next unless $game_map.valid?(x,y)
				if !Config.terrain_tag(@fow_tilemap.map_data[x,y,0]).fow_cover or
					($game_map.get_unit(x,y) != nil and $game_map.get_unit(x,y).move_type == MOVE_AIR)
          @fow_tilemap.map_data[x, y, 0] = 0
					next if y - 1 < 0
					@fow_tilemap.map_data[x, y-1, 1] = 0
				end
			}
			@fow_tilemap.map_data[prop.x, prop.y, 0] = 0
			next if prop.y - 1 < 0
			@fow_tilemap.map_data[prop.x, prop.y-1, 1] = 0
		}
		$scene.player.units.each{|unit|
			next if unit.loaded
			sight = $scene.calc_pos(unit, "vision")
			around = $game_map.get_spaces_in_area(unit.x, unit.y)
			sight.each{|pos|
				x, y = pos[0], pos[1]
				next unless $game_map.valid?(x,y)
				# Test for thick tiles
				if !Config.terrain_tag(@fow_tilemap.map_data[x,y,0]).fow_cover or 
				(around.include?([x,y]) or $scene.player.officer.pierce_fow or 
        ($game_map.get_unit(x,y) != nil and $game_map.get_unit(x,y).move_type == MOVE_AIR))
          
          @fow_tilemap.map_data[x, y, 0] = 0
          
					next if y-1 < 0
					@fow_tilemap.map_data[x, y-1, 1] = 0
				end
			}
		}
	end
	
	# Makes it so that properties that cannot be seen appear as neutral
	def format_fow_data
		for z in [0]
			for y in 0..$game_map.height-1
				for x in 0..$game_map.width-1
					t_id = @fow_tilemap.map_data[x,y,z]
					army = Config.army_ownership(t_id)
					next if army == 0
					unless [464, 465, 466, 467].include?(t_id)
						@fow_tilemap.map_data[x,y,z] -= army.id
						next if y-1 < 0
						@fow_tilemap.map_data[x,y-1,1] -= army.id
					end
				end
			end
		end
	end
end


