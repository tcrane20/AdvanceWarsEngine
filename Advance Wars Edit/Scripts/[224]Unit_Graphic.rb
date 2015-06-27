=begin
_____________________
 Unit_Graphic        \__________________________________________________________
 
 Draws currently highlighted unit graphic. Displays its stats as well in the
 stat window at the bottom. Controls the carried graphic object as well.
 
 Notes:
 * Updated every frame--no
 * Maybe combine its stat graphics and numbers into one file
 * Needs unit name
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Unit_Graphic < RPG::Sprite
  attr_accessor :carried_sprites
  attr_reader    :unit_exists    # If there is a unit at the cursor location
  #--------------------------------------------------------------------------
  # Initialize tile graphic
  #--------------------------------------------------------------------------
  def initialize(viewport=nil)
    super(viewport)
    @unit_exists = false
    self.bitmap = Bitmap.new(64, 96)
    # Create offset
    @carried_sprites = Carried_Graphic.new(viewport)
    self.x = 64
    self.y = 480 - 96
  end
  #--------------------------------------------------------------------------
  # Update the tile graphic
  #--------------------------------------------------------------------------
  def update
    super
    @unit_exists = false
    @carried_sprites.holding_exists = false
    update_graphic   # Changes the tile to draw
  end
  #--------------------------------------------------------------------------
  # Changes the tile graphic if needed
  #--------------------------------------------------------------------------
  def update_graphic
    self.bitmap.clear
    unit = $game_map.get_unit($game_player.x, $game_player.y, false)
    
    # Create the unit graphic if unit exists
    unless unit.nil?
      @unit_exists = true
      id = "_" + unit.army.id.to_s
      bitmap = RPG::Cache.character(unit.name + id, 0)
      rect = Rect.new(0, 0, 32, 32)
      self.bitmap.blt(16, 16, bitmap, rect)
      
      # Draw HP
      bitmap = RPG::Cache.picture("info_heart")
      rect = Rect.new(0, 0, 12, 12)
      self.bitmap.blt(4, 51, bitmap, rect)
      rect = Rect.new(0, 0, 12, 14)
      # If the HP should be hidden from view
      if unit.army.officer.hide_hp and !unit.army.playing
        bitmap = RPG::Cache.picture("info_hide")
        self.bitmap.blt(36, 51, bitmap, rect)
      else
        # If unit has single digit HP, and HP is not 0 or negative  
        if unit.unit_hp < 10 and unit.unit_hp > 0
          bitmap = RPG::Cache.picture("info_" + unit.unit_hp.to_s)
          self.bitmap.blt(36, 51, bitmap, rect)
        else
          bitmap = RPG::Cache.picture("info_1")
          self.bitmap.blt(24, 51, bitmap, rect)
          bitmap = RPG::Cache.picture("info_0")
          self.bitmap.blt(36, 51, bitmap, rect)
        end
      end
      
      # Draw Fuel
      bitmap = RPG::Cache.picture("info_fuel")
      rect = Rect.new(0, 0, 12, 12)
      self.bitmap.blt(4, 66, bitmap, rect)
      rect = Rect.new(0, 0, 12, 14)
      ten_digit = unit.fuel / 10
      one_digit = unit.fuel % 10
      
      if ten_digit > 0
        bitmap = RPG::Cache.picture("info_" + ten_digit.to_s)
        self.bitmap.blt(24, 66, bitmap, rect)
      end
      bitmap = RPG::Cache.picture("info_" + one_digit.to_s)
      self.bitmap.blt(36, 66, bitmap, rect)
      
      # Draw Ammo (if unit has any)
      if unit.max_ammo > 0
        bitmap = RPG::Cache.picture("info_ammo")
        rect = Rect.new(0, 0, 12, 12)
        self.bitmap.blt(4, 81, bitmap, rect)
        rect = Rect.new(0, 0, 12, 14)
        bitmap = RPG::Cache.picture("info_" + unit.ammo.to_s)
        self.bitmap.blt(36, 81, bitmap, rect)
      end
      
      # Draw Flag (capture, hide, carrying)
      bitmap = RPG::Cache.picture("capture") if unit.capturing
      bitmap = RPG::Cache.picture("load") if unit.holding_units.size > 0
      bitmap = RPG::Cache.picture("hide") if unit.hiding
      rect = Rect.new(0, 0, 16, 16)
      self.bitmap.blt(16, 32, bitmap, rect) if bitmap.width == 16
      
      # Update the @carried_sprites if unit is carrying something
      @carried_sprites.bitmap.clear
      @carried_sprites.update_graphic(unit) if unit.holding_units.size > 0
    else
      @carried_sprites.bitmap.clear
    end
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
