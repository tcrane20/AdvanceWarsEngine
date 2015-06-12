=begin
________________________
 Carried_Graphic        \_______________________________________________________
 
 Draws unit graphics that are being carried in the currently highlighted unit.
 Only allows two units to be drawn.
 
 Notes:
 * 
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Carried_Graphic < RPG::Sprite
	attr_accessor		:holding_exists	# If there is/are unit(s) being carried
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def initialize(viewport=nil)
    super(viewport)
		@holding_exists = false
    self.bitmap = Bitmap.new(64, 96)
    # Create offset
    self.x = 128
    self.y = 480 - 96
  end
  #--------------------------------------------------------------------------
  # Changes the tile graphic if needed
  #--------------------------------------------------------------------------
  def update_graphic(carrying_unit)
    update
    self.bitmap.clear
		y = 0
    carrying_unit.holding_units.each{|unit|
			@holding_exists = true
      # Draw the held unit
      id = "_" + unit.army.id.to_s
      bitmap = RPG::Cache.character(unit.name + id, 0)
      rect = Rect.new(0, 0, 32, 32)
      self.bitmap.blt(16, 16+y, bitmap, rect)
      # Draw Flag (capture, hide, carrying)
   #   bitmap = RPG::Cache.picture("capture") if unit.capturing
      bitmap = RPG::Cache.picture("load") if unit.holding_units.size > 0
      bitmap = RPG::Cache.picture("hide") if unit.hiding
      rect = Rect.new(0, 0, 16, 16)
      self.bitmap.blt(16, 32+y, bitmap, rect) if bitmap.width == 16
			y += 40
    }
  end
  #----------------------------------------------------------------------------
  # Dispose process
  #----------------------------------------------------------------------------
  def dispose
    unless self.bitmap == nil
      self.bitmap.dispose
      self.bitmap = nil
    end
    super
  end
  
end