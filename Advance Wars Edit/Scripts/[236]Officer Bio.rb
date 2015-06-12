=begin
__________________________
 OfficerBio_Window        \_____________________________________________________
 
 Fullscreen window that talks about the CO. Character info, strengths, powers...
 Handles input processing to view the other pages.
 
 Notes:
 * Clean up would be nice, as well as a better design. Maybe use window graphics
 that aren't the default red/white/blue windowskin? An animated background with
 black text on it is good enough.
 # Needs the unit proficiency window
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class OfficerBio_Window < Window_Base
	attr_accessor :delete
	def initialize(officer)
		super(0, 0, 640, 480)
		self.contents = Bitmap.new(640,480)
		@officer = officer
		@page = 0
		@delete = false
		# Draws the full standing CO to the right side of the window
		officer_sheet = RPG::Cache.picture("CO_" + @officer.name)
		rect = Rect.new(0,0,288,700)
		self.contents.blt(327,0,officer_sheet,rect)
		draw_bio
	end
	
	def update
		if Input.trigger?(Input::B)
			$game_system.se_play($data_system.cancel_se)
			@delete = true
			dispose
			return
    elsif Input.trigger?(Input::C)
      Config.play_se("pageturn")
      @page = (@page + 1) % 2
      draw_bio if @page == 0
      draw_powers if @page == 1
		else 
			case Input.dir4
			when 2
				unless @page == 1
					Config.play_se("pageturn")
					draw_powers 
					@page += 1
				end
			when 8
				unless @page == 0
					Config.play_se("pageturn")
					draw_bio 
					@page -= 1
				end
			end
		end
		super
	end
	
	def draw_bio
		self.contents.erase(0,0,325,480)
		draw_text(1, @officer.name + " of " + @officer.description[0])
		draw_text(3, @officer.description[3], true, 325)
		draw_text(7, "Hit: " + @officer.description[1])
		draw_text(8, "Miss: " + @officer.description[2])
		draw_text(10, @officer.description[4], true, 325)
	end
	
	def draw_powers
		self.contents.erase(0,0,325,480)
		draw_text(1, "Power: " + @officer.cop_name)
		draw_text(2, @officer.description[5], true, 325)
		draw_text(9, "Super Power: " + @officer.scop_name)
		draw_text(10, @officer.description[6], true, 325)
	end
	
	
end
