=begin
_________________________
 Unit_Info_Window        \______________________________________________________
 
 Large window that displays the stats of the unit in question. Shown during
 buying a unit and if the player presses R over a unit on the map. It's still
 a selectable window, meaning the window cursor can highlight different stats
 for more information in the Description Window.
 
 Notes:
 * Not friendly with the mouse yet
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Unit_Info_Window < Window_Selectable
	#-----------------------------------------------------------------------
	# Initialize the build window
	#     unit - the unit in question
	#-----------------------------------------------------------------------
	def initialize(unit, from_build_window = true)
		super(280, 80, 300, 50+(32*8))
		self.z = 10000
		#@active_mod_on = true
		@unit = unit
		self.contents = Bitmap.new(300, 32*8+50)
		self.windowskin = RPG::Cache.windowskin('AW_window1')
		@custom_update_method = true
		@disable_left_right_keys = from_build_window
		refresh
		self.index = 0
		self.active = false
		self.cursor_rect.visible = false
	end
	
	def set_desc_window(window)
		@desc_window = window
	end
	
	def unit=(u)
		@unit = u
		refresh
	end
	
	def index=(i)
		@index = i
		update_cursor_rect
	end
	
	def refresh
		self.contents.clear
		# Draw unit name
		self.contents.draw_text(0, 0, self.width, 40, @unit.real_name, 1)
		# Draw move, move type, vision, fuel
		bitmap = RPG::Cache.picture("unit_info_graphics")
		
		x = -1
		case @unit.move_type
		when 0 then x = 0
		when 1 then x = 64
		when 2,7 then x = 128
		when 3 then x = 192
		when 4 then x = 256
		when 5 then x = 320
		when 6 then x = 384
		end
		rect = Rect.new(x,60,64,28)
		self.contents.blt(0, 32, bitmap, rect) # Move
		self.contents.draw_text(80,34,100,32,@unit.move.to_s)
		
		rect = Rect.new(448,60,60,28)
		self.contents.blt(0, 64, bitmap, rect) # Vision
		self.contents.draw_text(80, 66,100,32,@unit.vision.to_s)
		
		rect = Rect.new(508,60,24,28)
		self.contents.blt(170, 48, bitmap, rect) # Fuel
		ones = @unit.fuel % 10
		tens = @unit.fuel / 10
		rect = Rect.new(512+12*(tens%5), 88+10*(tens/5), 12,10)
		self.contents.blt(200, 50, bitmap, rect)	# Tens digit
		rect = Rect.new(512+12*(ones%5),88+10*(ones/5),12,10)
		self.contents.blt(214, 50, bitmap, rect)	# Ones digit
		
		ones = @unit.max_fuel % 10
		tens = @unit.max_fuel / 10
		rect = Rect.new(512+12*(tens%5),88+10*(tens/5),12,10)
		self.contents.blt(224, 66, bitmap, rect)	# Tens digit
		rect = Rect.new(512+12*(ones%5),88+10*(ones/5),12,10)
		self.contents.blt(238, 66, bitmap, rect)	# Ones digit
		
		
		rect = Rect.new(0,88,256,80)
		self.contents.blt(17,110,bitmap,rect)			# Weapon 1 Backdrop
		rect = Rect.new(256,88,256,80)
		self.contents.blt(17,206,bitmap,rect)			# Weapon 2 Backdrop
		
		# Draw attack range
		if @unit.max_range > 1
			# Range graphic
			rect = Rect.new(532,60,50,16) 
			self.contents.blt(225, 94, bitmap,rect)
			# Determine if 2 digit or 1 digit range
			if @unit.max_range < 10
				# Min range
				rect = Rect.new(512+12*(@unit.min_range%5), 88+10*(@unit.min_range/5), 12,10)
				self.contents.blt(228, 114, bitmap, rect)
				# The ~ sign
				rect = Rect.new(588,88,12,6)
				self.contents.blt(242,116,bitmap,rect)
				# Max range
				rect = Rect.new(512+12*(@unit.max_range%5), 88+10*(@unit.max_range/5), 12,10)
				self.contents.blt(256, 114, bitmap,rect)
			else
				# Min range
				rect = Rect.new(512+12*(@unit.min_range%5), 88+10*(@unit.min_range/5), 12,10)
				self.contents.blt(219, 114, bitmap, rect)
				# The ~ sign
				rect = Rect.new(588,88,12,6)
				self.contents.blt(233,116,bitmap,rect)
				# Max range
				tens = @unit.max_range / 10
				ones = @unit.max_range % 10
				rect = Rect.new(512+12*(tens%5), 88+10*(tens/5), 12,10)
				self.contents.blt(247, 114, bitmap,rect)
				rect = Rect.new(512+12*(ones%5), 88+10*(ones/5), 12,10)
				self.contents.blt(261, 114, bitmap,rect)
			end
		end
		
		
		# AMMO
		if @unit.max_ammo > 0
			rect = Rect.new(512+12*(@unit.ammo%5), 88+10*(@unit.ammo/5), 12,10)
			self.contents.blt(170, 98, bitmap,rect)
			rect = Rect.new(512+12*(@unit.max_ammo%5), 88+10*(@unit.max_ammo/5), 12,10)
			self.contents.blt(188, 114, bitmap,rect)
		end
		
		# Draw all instances of the / sign
		rect = Rect.new(572,88,16,16)
		self.contents.blt(218,54,bitmap,rect)
		self.contents.blt(178,102,bitmap,rect) if @unit.max_ammo > 0
		
		# Draw weapons
		self.contents.draw_text(33, 91, self.width/2, 40, @unit.weapon1)
		self.contents.draw_text(33, 187, self.width/2, 40, @unit.weapon2)
		
		# Draw effective targets
		# Primary Weapons
		index = 0
		for v in 0...@unit.weapon1_effect.size
			value = @unit.weapon1_effect[v]
			next unless [1,2].include?(value)
			# If the index extends beyond the rectangle
			if index >= 4
				i = index - 4
				if value == 2
					rect = Rect.new(v * 100, 0, 50, 60)
				elsif value == 1
					rect = Rect.new(v * 100 + 50, 0, 50, 60)
				end
				self.contents.blt(27 + (i*64),224,bitmap,rect)
				index += 1
				# Go to next value in array
				next
			elsif value == 2
				rect = Rect.new(v * 100, 0, 50, 60)
			elsif value == 1
				rect = Rect.new(v * 100 + 50, 0, 50, 60)
			end
			self.contents.blt(27 + (index*64),128,bitmap,rect)
			index += 1
		end
		# Secondary Weapons
		if index <= 4
			index = 0
			for v in 0...@unit.weapon2_effect.size
				value = @unit.weapon2_effect[v]
				next unless [1,2].include?(value)
				# If the index extends beyond the rectangle
				if index == 4
					raise("This unit cannot have a secondary weapon that hits more than 4 unit types.")
				elsif value == 2
					rect = Rect.new(v * 100, 0, 50, 60)
				elsif value == 1
					rect = Rect.new(v * 100 + 50, 0, 50, 60)
				end
				self.contents.blt(27 + (index*64),224,bitmap,rect)
				index += 1
			end
		end
		
	end
	
	#--------------------------------------------------------------------------
	# * Update Cursor Rectangle
	#--------------------------------------------------------------------------
	def update_cursor_rect
		# If cursor position is less than 0
		if @index < 0
			self.cursor_rect.empty
			return
		end
		# Get current row
		row = @index / @column_max
		# If current row is before top row
		if row < self.top_row
			# Scroll so that current row becomes top row
			self.top_row = row
		end
		# If current row is more to back than back row
		if row > self.top_row + (self.page_row_max - 1)
			# Scroll so that current row becomes back row
			self.top_row = row - (self.page_row_max - 1)
		end
		
		# Calculate cursor coordinates, width, and height
		case @index
		when 0 then self.cursor_rect.set(0, 0, self.width, 40) # Name
		when 1 then self.cursor_rect.set(0, 34, 110, 40) # Move
		when 2 then self.cursor_rect.set(0, 63, 110, 40) # Vision
		when 3 then self.cursor_rect.set(167, 44, 98, 40) # Fuel
		when 4 then self.cursor_rect.set(26, 97, self.contents.text_size(@unit.weapon1).width + 20, 40) # Weapon 1
		when 5 then self.cursor_rect.set(26, 128, 58, 67) # Target 1 (Primary weapon)
		when 6 then self.cursor_rect.set(90, 128, 58, 67) # Target 2
		when 7 then self.cursor_rect.set(154, 128, 58, 67) # Target 3
		when 8 then self.cursor_rect.set(218, 128, 58, 67) # Target 4
		when 9 then self.cursor_rect.set(26, 193, self.contents.text_size(@unit.weapon2).width + 20, 40) # Weapon 2
		when 10 then self.cursor_rect.set(26, 224, 58, 67)# Target 1 (Secondary weapon)
		when 11 then self.cursor_rect.set(90, 224, 58, 67)# Target 2
		when 12 then self.cursor_rect.set(154, 224, 58, 67)# Target 3
		when 13 then self.cursor_rect.set(218, 224, 58, 67)# Target 4
		end

	end
	
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
		super
		# If cursor is movable
		if self.active and @index >= 0
			# If pressing down on the directional buttons
			if Input.repeat?(Input::DOWN)
				# If column count is 1 and directional button was pressed down with no
				# repeat, or if cursor position is more to the front than
				# (item count - column count)
				$game_system.se_play($data_system.cursor_se)
				if @index < 13
					# Move cursor down
					@index += 1
					# If the next spot has no description
					while @unit.stat_desc[@index] == ""
						@index += 1
						# Reached end of stat list, jump to top
						if @index == 14
							@index = 0
							break
						end
					end
				else
					@index = 0
				end
			end
			# If the up directional button was pressed
			if Input.repeat?(Input::UP)
				# If column count is 1 and directional button was pressed up with no
				# repeat, or if cursor position is more to the back than column count
				$game_system.se_play($data_system.cursor_se)
				if @index > 0
					# Move cursor up
					@index -= 1
					while @unit.stat_desc[@index] == ""
						@index -= 1
						# Reached end of stat list, jump to bottom
						if @index == -1
							@index = 13
							break
						end
					end
				else
					@index = 13
					while @unit.stat_desc[@index] == ""
						@index -= 1
					end
				end
			end
			# If the right directional button was pressed
			if !@disable_left_right_keys and Input.repeat?(Input::RIGHT)
				# If column count is 2 or more, and cursor position is closer to front
				# than (item count -1)
				$game_system.se_play($data_system.cursor_se)
				if @index < 13
					# Move cursor down
					@index += 1
				else
					@index = 0
				end
			end
			# If the left directional button was pressed
			if !@disable_left_right_keys and Input.repeat?(Input::LEFT)
				# If column count is 2 or more, and cursor position is more back than 0
				$game_system.se_play($data_system.cursor_se)
				if @index > 0
					# Move cursor up
					@index -= 1
				else
					@index = 13
				end
			end
		end
		# Update help text (update_help is defined by the subclasses)
		if self.active
			@desc_window.draw_info(@unit.stat_desc[@index])
		end
		# Update cursor rectangle
		update_cursor_rect
	end
	
	
end
