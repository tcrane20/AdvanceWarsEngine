=begin
____________________________
 Unit_Command_Window        \___________________________________________________
 
 That small window that appears after choosing a move location. Draws all the
 possible actions that unit can perform at that spot. User selects one and the
 action is returned to the scene to process.
 
 Notes:
 * 
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Unit_Command_Window < Window_Command
	
	attr_accessor :two_drop_commands
	
	def initialize(width, commands, use_icons = false, unit = nil)
		super(width, commands, use_icons, unit)
		self.z = 10000
		x = ($game_player.real_x - $game_map.display_x) / 4
		x -= (self.width / 2 - 16)
		y = ($game_player.real_y - $game_map.display_y) / 4
		set_at(x, y)
		@original_commands = commands
		@two_drop_commands = (@commands.include?("Drop") and @commands.include?("Drop "))
	end
	
	def command
		return @commands[self.index]
	end
	#--------------------------------------------------------------------------
	# Creates a different list of commands if a first unit was dropped.
	#--------------------------------------------------------------------------
	def new_commands(list)
		#@original_commands = @commands.clone
		#@commands.delete_at(self.index)
		#@commands.delete("Fire")
		#@commands.delete("Fire ")
		#@commands[@commands.index("Wait")] = "Wait "
		if list[0].nil?
      @commands = ["Drop "]
    else
      @commands = ["Drop"]
    end
    @commands.push("Wait ")
    @item_max = @commands.size
		self.height -= 32
		refresh
	end
	
	def revert_commands
		@commands = @original_commands
		refresh
	end
	
	
end
