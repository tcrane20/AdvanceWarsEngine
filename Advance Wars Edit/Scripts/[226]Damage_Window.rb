=begin
______________________
 Damage_Window        \_________________________________________________________
 
 Not exactly a window in RPG Maker terms. Rectangular graphic that appears at
 the bottom over the stat window when choosing a target to attack.
 
 Notes:
 * Needs animation still
 * Constantly redrawn each turn--stop dat
 * Positioning is not correct.
 
 Updates:
 - XX/XX/XX
 - 3/16/14
   + Positioning has been fixed. Now displays properly over unit or tile
     depending on the target.
________________________________________________________________________________
=end
class Damage_Window < RPG::Sprite
  def initialize(viewport=nil)
    super(viewport)
    self.bitmap = Bitmap.new(64, 49)
    @frame = 0
    @damage = nil
    # Create offset
    self.x = 0
    self.y = 480 - 96 - 49
  end
  #--------------------------------------------------------------------------
  # Update method
  #--------------------------------------------------------------------------
  def update
    super
    update_graphic
  end
  
  #--------------------------------------------------------------------------
  # Changes the tile graphic if needed
  #--------------------------------------------------------------------------
  def update_graphic
    attacker = $scene.unit
    # Get damage
    if attacker.nil?
      self.bitmap.clear
      return
    end
    defender = $game_map.get_unit($game_player.x, $game_player.y, false)
    defender = $game_map.get_tile($game_player.x, $game_player.y) if defender.nil?
    if defender.is_a?(Structure) and defender.hp > 0
      damage = determine_damage(attacker, defender)
      damage = 999 if damage > 999
      self.x += 128 if self.x > 320
      return if damage <= -1
    elsif defender.is_a?(Unit)
      unless attacker == defender or attacker.army.team == defender.army.team
        damage = determine_damage(attacker, defender)
        damage = 999 if damage > 999
        self.x += 64
        return if damage <= -1
      end
    end
    return if @damage == damage
    @damage = damage
    self.bitmap.clear
    return if @damage.nil?
    # Draw damage window
    bitmap = RPG::Cache.picture("damage_window")
    rect = Rect.new(0, 0, 64, 49)
    self.bitmap.blt(0, 0, bitmap, rect)
    # Draw damage
    rect = Rect.new(0, 0, 16, 26)
    hundreds = damage / 100
    if hundreds >= 1
      bitmap = RPG::Cache.picture("damage_" + hundreds.to_s)
      self.bitmap.blt(4, 14, bitmap, rect)
    end
    damage = damage % 100
    tens = damage / 10
    if tens >= 1 or hundreds >= 1
      bitmap = RPG::Cache.picture("damage_" + tens.to_s)
      self.bitmap.blt(20, 14, bitmap, rect)
    end
    damage = damage % 10
    bitmap = RPG::Cache.picture("damage_" + damage.to_s)
    self.bitmap.blt(36, 14, bitmap, rect)
  end
  
  #-----------------------------------------------------------------------------
  # Gets the damage done. Unit1 attacking Unit2
  #-----------------------------------------------------------------------------
  def determine_damage(unit1, unit2)
    # If target is a structure
    if unit2.is_a?(Structure)
      if unit1.ammo == 0 or unit2.damage_chart[0][unit1.unit_type] == -1
        damage = unit2.damage_chart[1][unit1.unit_type] * unit1.unit_hp / 10
        unit1.weapon_use = 2
      else
        damage = unit2.damage_chart[0][unit1.unit_type] * unit1.unit_hp / 10
        unit1.weapon_use = 1
      end
      damage = damage * unit1.offense_power / 100
      return damage.floor
    # Else target is a unit
    elsif unit1.ammo == 0 or DamageChart::PriDamage[unit1.unit_type][unit2.unit_type] == -1
      damage = DamageChart::SecDamage[unit1.unit_type][unit2.unit_type] * unit1.unit_hp / 10
      unit1.weapon_use = 2
    else
      damage = DamageChart::PriDamage[unit1.unit_type][unit2.unit_type] * unit1.unit_hp / 10
      unit1.weapon_use = 1
    end
    return -1 if damage <= -1
    damage *= unit1.offense_power
    damage /= unit2.defense_power
    damage = damage * unit2.terrain_defense / 100
    return damage
  end

end
