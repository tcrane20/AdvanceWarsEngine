=begin
_____________________
 Gold_Graphic        \__________________________________________________________
 
 Draws the player's funds at the top of the screen. Pretty basic. Uses blt's
 everywhere.
 
 Notes:
 * Combine the graphics together into one file
 * It's okay for now right?
 
 Updates:
 - 11/04/14
   + Revamped the drawing method to not do division but string manipulation.
________________________________________________________________________________
=end
class Gold_Graphic < RPG::Sprite
	
	def initialize(viewport, army)
		super(viewport)
		self.bitmap = Bitmap.new(200, 86)
		@army = army
		@last_funds = -1
    self.z = 9000
	end
	
	def update
		super
		update_funds
	end
	
	def update_funds
		# Only call the update method if funds change
		return if @last_funds == @army.funds
		self.bitmap.clear
		# Draw "G." graphic
		bitmap = RPG::Cache.picture("gold_letter")
		rect = Rect.new(0,0,20,24)
		self.bitmap.blt(0,62,bitmap,rect)
		# Set the new funds
		@last_funds = @army.funds
    funds = @army.funds.to_s
    rect = Rect.new(0,0,12,24)
    
    i = 6 - funds.size
    funds.split(//).each{|num|
      bitmap = RPG::Cache.picture("gold_" + num)
      self.bitmap.blt(20 + i*12, 62, bitmap, rect)
      i += 1
    }
  end
  
    
=begin
		funds = @army.funds.to_i
		# Begin drawing the funds digit by digit
		rect = Rect.new(0, 0, 12, 24)
    
		if @army.funds >= 100000
			bitmap = RPG::Cache.picture("gold_" + (funds / 100000).to_s)
			self.bitmap.blt(20,62,bitmap,rect)
		end
		funds = funds % 100000
		if @army.funds >= 10000
			bitmap = RPG::Cache.picture("gold_" + (funds / 10000).to_s)
			self.bitmap.blt(32,62,bitmap,rect)
		end
		funds = funds % 10000
		if @army.funds >= 1000
			bitmap = RPG::Cache.picture("gold_" + (funds / 1000).to_s)
			self.bitmap.blt(44,62,bitmap,rect)
		end
		funds = funds % 1000
		if @army.funds >= 100
			bitmap = RPG::Cache.picture("gold_" + (funds / 100).to_s)
			self.bitmap.blt(56,62,bitmap,rect)
		end
		funds = funds % 100
		if @army.funds >= 10
			bitmap = RPG::Cache.picture("gold_" + (funds / 10).to_s)
			self.bitmap.blt(68,62,bitmap,rect)
		end
		funds = funds % 10
		bitmap = RPG::Cache.picture("gold_" + funds.to_s)
		self.bitmap.blt(80,62,bitmap,rect)
	end
=end	
end
