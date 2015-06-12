=begin
________________________
 Minimap_Graphic        \______________________________________________________
 
 Draws the map's minimap. Should also handle animation and flashing unit dots.
 Drawn during map selection and pressing Select button during battle.
 
 Notes:
 * Still need to implement this when called from game map scene
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Minimap_Graphic < Sprite
	
	def initialize(map, viewport=nil)
		super(viewport)
		@data = map.data
		#self.bitmap = Bitmap.new(map.width*8, map.height*8)
    self.bitmap = Bitmap.new(640, 480)
		minimap_graphic = RPG::Cache.picture('minimap_graphic')
    sx = (640 - map.width*8) / 2
		sy = (480 - map.height*8) / 2
		# Draw the minimap
		for x in 0...map.width
			for y in 0...map.height
				tile = @data[x,y,0]
				type = Config.terrain_tag(tile)
				id = Config.minimap_tiles(type, tile)
				ox = id % 8
				oy = id / 8
        self.bitmap.blt(sx+x*8,sy+y*8, minimap_graphic, Rect.new(ox*8,oy*8,8,8))
				#self.bitmap.blt(x*8,y*8, minimap_graphic, Rect.new(ox*8,oy*8,8,8))
			end
		end
		#self.x = (640 - self.bitmap.width) / 2
		#self.y = (480 - self.bitmap.height) / 2
    
    # Draws a portion of the minimap overlapping the window to be transparent
    rect = Rect.new(40,50,180,8+12*32)
    saved_bitmap = Bitmap.new(180,8+12*32)
    saved_bitmap.blt(0, 0, self.bitmap, rect, 128)
    self.bitmap.fill_rect(rect, Color.new(0,0,0,0))
    self.bitmap.blt(40,50,saved_bitmap,Rect.new(0,0,180,8+12*32))
    
	end
	
	# Draw the minimap
  # Get the rectangle that overlaps the window(s)
	# Save that rectangle as a bitmap
  # Use a clear rectangle in that same section on the minimap
  # 'blt' the saved bitmap back onto the minimap with changed opacity
	
	
	
end
