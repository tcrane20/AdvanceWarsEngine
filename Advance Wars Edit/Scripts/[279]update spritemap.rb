	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
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
    
		# If panorama is different from current one
		if @panorama_name != $game_map.panorama_name or
			@panorama_hue != $game_map.panorama_hue
			@panorama_name = $game_map.panorama_name
			@panorama_hue = $game_map.panorama_hue
			if @panorama.bitmap != nil
				@panorama.bitmap.dispose
				@panorama.bitmap = nil
			end
			if @panorama_name != ""
				@panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
			end
			Graphics.frame_reset
		end
		# If fog is different than current fog
		if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
			@fog_name = $game_map.fog_name
			@fog_hue = $game_map.fog_hue
			if @fog.bitmap != nil
				@fog.bitmap.dispose
				@fog.bitmap = nil
			end
			if @fog_name != ""
				@fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
			end
			Graphics.frame_reset
		end
		# Update tilemap
		@tilemap.ox = $game_map.display_x / 4
		@tilemap.oy = $game_map.display_y / 4
		@tilemap.update(@tiletype_table.flatten.compact)
    
		# Update panorama plane
		@panorama.ox = $game_map.display_x / 8
		@panorama.oy = $game_map.display_y / 8
		# Update fog plane
		@fog.zoom_x = $game_map.fog_zoom / 100.0
		@fog.zoom_y = $game_map.fog_zoom / 100.0
		@fog.opacity = $game_map.fog_opacity
		@fog.blend_type = $game_map.fog_blend_type
		@fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
		@fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
		@fog.tone = $game_map.fog_tone
		# Update character sprites
		for sprite in @character_sprites
			sprite.update
		end
		

    unless @first_update
      # Update the cursor sprite
			@player_sprite.update
      @player_sprite.visible = $game_player.visible
      # Update officer tag
      @officer_tag.update unless @officer_tag.nil?
      # Update info window (gray rectangle at bottom corners)
      @info_window.update
    end
		# Update weather graphic
		@weather.type = $game_screen.weather_type
		@weather.max = $game_screen.weather_max
		@weather.ox = $game_map.display_x / 4
		@weather.oy = $game_map.display_y / 4
		@weather.update
		# Update picture sprites
		for sprite in @picture_sprites
			sprite.update
		end
		
		# Update timer sprite
		@timer_sprite.update
		# Set screen color tone and shake position
		@viewport1.tone = $game_screen.tone
		@viewport1.ox = $game_screen.shake
		# Set screen flash color
		@viewport3.color = $game_screen.flash_color
		# Update viewports
		@viewport1.update
    @viewport2.update
		@viewport3.update
	end