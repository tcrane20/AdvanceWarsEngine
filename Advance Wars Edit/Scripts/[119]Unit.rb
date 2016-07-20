=begin
_____________
 Unit        \__________________________________________________________________
 
 All the information needed for just one unit. Each unit type is a child of this
 class. Lots of methods and variables. Really needs to be organized.
 
 Notes:
 * No floats
 * Organize it better, hot damn
 * Fire method needs to be reworked if I want battle animations
 * can_attack method needs to be reworked (bugged at the moment)
 
 Updates:
 - 11/02/14
   + More cleaning; added parameters to some attribute methods to get base stats
   + <fire> has been overhauled completely
   + Moved <charge_power> to Army class
   + <test_drop_tile> editted with global definition
   + Does not save the Sprite object anymore; accesses array in Spriteset_Map
 - 04/10/14
   + Starting to clean things up. Just general stuff so far.
________________________________________________________________________________
=end
class Unit
  attr_accessor :army           # Which army it belongs to (Army object)
  attr_accessor :name           # Character graphic file name
  attr_accessor :real_name      # Actual in-game name
  attr_accessor :unit_type      # Integer-value representing type of unit
  attr_accessor :cost           # Base purchase price
  attr_accessor :move           # Number of spaces to move
  attr_accessor :move_type      # Type of movement (foot, wheels, air, etc.) (Integer)
  attr_accessor :vision         # Number of spaces it can see
  attr_accessor :health         # HP of unit
  attr_accessor :max_fuel       # Maximum fuel amount
  attr_accessor :fuel           # Fuel remaining
  attr_accessor :fuel_cost      # Amount of fuel used per day
  attr_accessor :max_ammo       # Maximum ammo
  attr_accessor :ammo           # Ammo remaining
  attr_accessor :min_range      # Minimum attack range
  attr_accessor :max_range      # Maximum attack range
  attr_accessor :weapon1        # Name of primary weapon
  attr_accessor :weapon2        # Name of secondary weapon
  attr_accessor :star_energy    # Amount of S/COP power that is charged when attacked
  attr_accessor :x              # Map x-coordinate
  attr_accessor :y              # Map y-coordinate
  attr_accessor :move_se        # The sound file played when moving the unit
  attr_accessor :acted          # If unit has made its move
  attr_accessor :frame          # Animation frame (0, 1, 2, 3, 0...)
  attr_accessor :holding_units  # Units that are being carried within (array of Unit objects)
  attr_accessor :loaded         # If unit is being carried or not (T/F)
  attr_accessor :made_repairs   # If unit was repaired on property this day
  attr_accessor :status_effects # Holds all the status effects applied to the unit
  attr_accessor :needs_deletion # If unit needs to be deleted
  attr_accessor :destroyed      # If unit needs to explode
  # Actions the unit can perform
  attr_accessor :can_capture    # Gives unit "Capt" and "Launch" commands
  attr_accessor :can_carry      # Unit can "Load" other units
  attr_accessor :can_supply     # Gives "Supply" command
  attr_accessor :can_daily_supply # Unit can supply surrounding units
  attr_accessor :can_dive       # Gives "Dive" command
  attr_accessor :can_hide       # Gives "Hide" command
  # For status flag purposes
  attr_accessor :weapon_use     # 1 = Primary, 2 = Secondary
  attr_accessor :capturing      # If unit is capturing
  attr_reader   :property_capt  # The Property object being captured
  attr_accessor :hiding         # If unit is hidden (subs/stealths)
  attr_accessor :exposed        # If unit is visible to the player
  attr_accessor :disabled       # If unit is paralyzed (cannot move next turn)
  # For selection purposes
  attr_accessor :selected       # If unit is currently being selected
  # Graphics
  attr_reader   :stat_desc      # Holds array of unit info descriptions
  attr_reader   :weapon1_effect  # Array containing primary effectiveness
  attr_reader   :weapon2_effect  # Array containing secondary effectiveness
  attr_accessor :sprite_id      # Index to find unit's sprite
  attr_accessor :trap           # If the unit encountered a TRAP
#  attr_accessor :play_animation # Play the explosion animation if destroyed
  attr_accessor :ai
  
  def initialize(x=nil, y=nil, army=nil)
    @army = army
    @nation_gfx = false
    @unit_type = -1
    @cost = 0
    @move = 1
    @move_type = MOVE_FOOT
    @vision = 1
    @health = 100
    @max_fuel = 99
    @fuel = 99
    @fuel_cost = 0
    @max_ammo = 0
    @ammo = 0
    @min_range = 1
    @max_range = 1
    @weapon1 = "None"
    @weapon2 = "None"
    @weapon1_effect = [0, 0, 0, 0, 0, 0]  # INF, VEH, SHP, SUB, CPT, PLN
    @weapon2_effect = [0, 0, 0, 0, 0, 0]  #0=no hit, 1=weak, 2=strong
    @offense = 0
    @defense = 0
    @star_energy = 0
    @x = x
    @y = y
    @move_se = ""
    @holding_units = []
    @loaded = false
    @made_repairs = false
    @status_effects = []
    @needs_deletion = false
    @destroyed = false
    
    @can_capture = false
    @can_carry = false
    @can_supply = false
    @can_daily_supply = false
    @can_dive = false
    @can_hide = false
    
    @property_capt = nil
    @capturing = false
    @carrying = false
    @hiding = false
    @disabled = false
    @exposed = false
    @acted = true 
    @frame = ($game_map.nil? ? 0 : Graphics.frame_count % 60 / 15) # frame_count ranges from 0-39
    @selected = false
    @trap = false
    
    @ai = Unit_AI.new
  end
  
  #~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
  # A T T R I B U T E S
  #~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

  #-----------------------------------------------------------------------------
  # Appends an integer to the end of @name to signify which graphic to use
  # based on the army's nation (1 = Orange Star, 2 = Blue Moon, etc.).
  # An army-less unit will default to 1.
  # Units must set @nation_gfx to true in order to enable this feature.
  #-----------------------------------------------------------------------------
  def name
    if @nation_gfx
      return @army.nil? ? @name + "1" : @name + army.get_nation.to_s
    else
      return @name
    end
  end
  #-----------------------------------------------------------------------------
  # Get unit's CO
  #-----------------------------------------------------------------------------
  def co
    return @army.officer
  end
  #-----------------------------------------------------------------------------
  # X-set method
  #-----------------------------------------------------------------------------
  def x=(value)
    # Ignore setting the unit at an impossible location
    return if value < 0 or value >= $game_map.width
    # If previous spot was this unit
    if $game_map.get_unit(@x, @y) == self
      # Remove this unit at that old spot
      $game_map.set_unit(@x, @y, nil)
    end
    # Set the unit's new spot
    @x = value
    # Put this unit at this new spot unless another unit already exists here
    $game_map.set_unit(@x, @y, self) if $game_map.get_unit(@x,@y).nil?
  end
  #-----------------------------------------------------------------------------
  # Y-set method
  #-----------------------------------------------------------------------------
  def y=(value)
    # Ignore setting the unit at an impossible location
    return if value < 0 or value >= $game_map.height
    # If previous spot was this unit
    if $game_map.get_unit(@x, @y) == self
      # Remove the unit at that old spot
      $game_map.set_unit(@x, @y, nil)
    end
    # Set the unit's new spot
    @y = value
    # Put this unit at this new spot unless another unit already exists here
    $game_map.set_unit(@x, @y, self) if $game_map.get_unit(@x,@y).nil?
  end
  #-----------------------------------------------------------------------------
  # Set real health
  #-----------------------------------------------------------------------------
  def health=(amt)
    @health = amt.to_i
    @health = 100 if @health > 100
  end
  #-----------------------------------------------------------------------------
  # Returns the unit's visible HP (1 to 10)
  #-----------------------------------------------------------------------------
  def unit_hp
    return (@health + 9) / 10
  end
  #-----------------------------------------------------------------------------
  # Set fuel
  #-----------------------------------------------------------------------------
  def fuel=(amt)
    @fuel = amt.to_i
    @fuel = @max_fuel if @fuel > @max_fuel
    @fuel = 0 if @fuel < 0
  end
  #-----------------------------------------------------------------------------
  # Set ammo
  #-----------------------------------------------------------------------------
  def ammo=(amt)
    @ammo = amt.to_i
    @ammo = @max_ammo if @ammo > @max_ammo
  end
  #-----------------------------------------------------------------------------
  # Check if the unit has a secondary weapon
  #-----------------------------------------------------------------------------
  def secondary
    DamageChart::SecDamage[@unit_type].each{|u| return true if u >= 0 }
    return false
  end
  #-----------------------------------------------------------------------------
  # Get unit cost 
  #-----------------------------------------------------------------------------
  def cost(officer = false)
    return @cost unless officer
    return @cost * co.cost_multiplier / 100
  end
  #-----------------------------------------------------------------------------
  # Get unit's movement
  #-----------------------------------------------------------------------------
  def move(officer = true)
    return @move unless officer
    return @move + co.move_bonus(self)
  end
  #-----------------------------------------------------------------------------
  # Get unit's vision
  #-----------------------------------------------------------------------------
  def vision(officer = true)
    return @vision unless officer
    tile = $game_map.get_tile(@x, @y)
    bonus = (tile.nil? ? 0 : tile.fow_bonus(self))
    if $game_map.current_weather == 'rain' and !co.no_rain_penalty
      bonus -= 1
    end
    return [1, @vision + co.vision_bonus(self) + bonus].max
  end
  #-----------------------------------------------------------------------------
  # Get unit's maximum attack range
  #-----------------------------------------------------------------------------
  def max_range(officer = true)
    return @max_range unless officer
    return @max_range + co.range_bonus(self)
  end
  #-----------------------------------------------------------------------------
  # Get daily fuel consumption
  #-----------------------------------------------------------------------------
  def daily_fuel_cost(officer = true)
    return @fuel_cost unless officer
    return @fuel_cost + co.fuel_burn_bonus(self)
  end
  #-----------------------------------------------------------------------------
  # True offensive power
  #-----------------------------------------------------------------------------
  def offense_power
    return @offense + co.atk_bonus(self) + (@army.num_of_property(ComTower) * 10) + get_status_effects('offense')
  end
  #-----------------------------------------------------------------------------
  # Luck bonus (calculates Positive minus Negative luck bonuses)
  #-----------------------------------------------------------------------------
  def luck_bonus(max = false, type = TOTLuck)
    # If trying to get maximum luck (mainly for AI)
    if max
      luck = co.luck_bonus(self)                            if type == POSLuck
      luck = co.neg_luck_bonus(self)                        if type == NEGLuck
      luck = co.luck_bonus(self) - co.neg_luck_bonus(self)  if type == TOTLuck
    else # Calculating for damage
      luck = rand(co.luck_bonus(self)+1) - rand(co.neg_luck_bonus(self)+1)
    end
    # Officer does not suffer decreased luck for damaged units
    return luck if co.no_luck_penalty
    return luck * unit_hp / 10
  end
  #-----------------------------------------------------------------------------
  # Defense Luck bonus
  #-----------------------------------------------------------------------------
  def def_luck_bonus(max = false)
    # If trying to get maximum luck (mainly for AI), get full luck;
    # Else, get random luck amount
    luck = (max ? co.def_luck_bonus(self) : rand(co.def_luck_bonus(self)+1))
    return luck * unit_hp / 10
  end
  #-----------------------------------------------------------------------------
  # True defensive power
  #-----------------------------------------------------------------------------
  def defense_power
    return @defense + co.def_bonus(self) + get_status_effects('defense')
  end
  #-----------------------------------------------------------------------------
  # Terrain defense power
  #-----------------------------------------------------------------------------
  def terrain_defense
    return 100 if @move_type == MOVE_AIR
    tile = $game_map.get_tile(@x,@y)
    return 100 - ( ([tile.defense + co.terrain_stars(tile) - @army.reduced_terrain_stars, 0].max) * unit_hp) * (co.terrain_defense(tile) / 100)
  end
  
  #~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
  # F U N C T I O N S
  #~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*

  #-----------------------------------------------------------------------------
  # Create the graphic for this unit
  #-----------------------------------------------------------------------------
  def init_sprite
    $spriteset.draw_unit(self)
  end
  #-----------------------------------------------------------------------------
  # Access the unit's sprite
  #-----------------------------------------------------------------------------
  def sprite
    return $spriteset.unit_sprites[@sprite_id]
  end
  #-----------------------------------------------------------------------------
  # Return true if not at full ammo AND fuel
  #-----------------------------------------------------------------------------
  def need_supplies
    return @ammo < @max_ammo || @fuel < @max_fuel
  end
  #-----------------------------------------------------------------------------
  # Removes the unit from the map. This method is also called when units are
  # joining together and follows a different procedure, thus the parameter.
  #-----------------------------------------------------------------------------
  def destroy(by_joining = false)
    # Delete all units this unit was carrying, and any units those held units
    # were carrying as well (e.g. Lander >> APC >> Infantry)
    @holding_units.each{|u| u.holding_units.each{|i| 
        index = i.army.units.index(i) 
        i.army.units[index] = nil
      }
      index = u.army.units.index(u)
      u.army.units[index] = nil
    }
    # If joining units rather than destroying them
    if by_joining
      index = @army.units.index(self)
      @army.units[index] = nil
    else # Play destruction animation
      # Stops capture of the unit if destroyed in battle
      stop_capture
      # The cursor will move to this unit before playing the destroy animation.
      # After the destroy animation, the cursor will continue to the next action.
      proc = Proc.new{ @destroyed = true; $game_map.set_unit(@x,@y,nil)}
      $game_player.add_move_action(@x, @y, proc, WAIT_UNIT_ANIMATION)
    end
    # For Spriteset_Map update phase
    @needs_deletion = true
  end
  #-----------------------------------------------------------------------------
  # Burns daily fuel. Destroys unit if it's an air or sea unit.
  #-----------------------------------------------------------------------------
  def daily_fuel
    # Do not drain fuel if this unit is loaded in something
    return if @loaded
    # Reduce fuel by factoring in officer bonus
    @fuel -= daily_fuel_cost(true)
    # Destroy if 0 fuel and air/sea unit. Otherwise, keep fuel at 0.
    if @fuel <= 0
      if [MOVE_AIR,MOVE_TRANS,MOVE_SEA].include?(@move_type)
        destroy
      else
        @fuel = 0
      end
    end
  end
  #-----------------------------------------------------------------------------
  # Heals the unit by real amount of health
  #-----------------------------------------------------------------------------
  def heal(amt)
    return if amt < 0 || @health <= 0
    @health += amt
    @health = 100 if @health > 100
  end
  #-----------------------------------------------------------------------------
  # Heals the unit by a certain HP. even_repair will round the HP up to the
  # closest integer (5.2 + 2 = 8.0) (remember 5.2 = 6 HP)
  #-----------------------------------------------------------------------------
  def repair(hp, even_repair = true)
    return if hp < 0
    @health += hp * 10
    @health = (@health + 9) / 10 * 10 if even_repair
    @health = 100 if @health > 100
  end
  #-----------------------------------------------------------------------------
  # Captures a property
  #-----------------------------------------------------------------------------
  def capture(property)
    # Set flag
    @capturing = true
    # Save property
    @property_capt = property
    # Get officer capturing bonus and apply it along with unit's HP
    bonus = co.capt_bonus
    if bonus[0] == "add"
      property.capt -= unit_hp + bonus[1]
    elsif bonus[0] == "mult"
      property.capt -= unit_hp * bonus[1] / 100
    else
      property.capt -= unit_hp
    end
    # If the property has been fully captured
    if property.capt <= 0
      # Turn off flag
      @capturing = false
      # Reset the capture points
      property.capt = 20
      # Set property as army owned
      $game_map.prop_army(x, y, self.army)
      # Play cheering sound effect
      Config.play_se("cheer")
    end
  end
  #-----------------------------------------------------------------------------
  # Cancels capturing
  #-----------------------------------------------------------------------------
  def stop_capture
    return if !@capturing
    # Turn off flag
    @capturing = false
    # Reset the capture points
    @property_capt.capt = 20
    @property_capt = nil
  end
  #-----------------------------------------------------------------------------
  # Determine if the unit can join with 'unit'
  #-----------------------------------------------------------------------------
  def can_join?(unit)
    # Can join if same unit type, has less than 10 HP, and both units are
    # not carrying other units
    return unit.unit_type == @unit_type && unit.unit_hp < 10 && 
    unit.holding_units.size == 0 && @holding_units.size == 0
  end
  #-----------------------------------------------------------------------------
  # Joins the units together. This unit is destroyed while 'u' remains alive.
  #-----------------------------------------------------------------------------
  def join(u)
    # If combined unit HP is more than 10, add cost of excess HP to funds
    if u.unit_hp + self.unit_hp > 10
      remainder = u.unit_hp + self.unit_hp - 10
      @army.funds += (self.cost * remainder) / 10
    end
    # Adds unit health, fuel, and ammo together
    u.repair(self.unit_hp)
    u.fuel += @fuel
    u.ammo += @ammo
    destroy(true)
    # Sets this unit to having acted
    u.acted = true
    # not sure if necessary...prolly not
    $game_map.set_unit(@x,@y,u)
    self.sprite.dispose # is this a good idea
  end
  #-----------------------------------------------------------------------------
  # Supplies the unit with full supplies. 'condition' determines what specific
  # material is supplied. 0 = Fuel and Ammo, 1 = only Fuel, 2 = only Ammo
  #-----------------------------------------------------------------------------
  def supply(condition = 0)
    @fuel = @max_fuel unless condition == 2
    @ammo = @max_ammo unless condition == 1
  end
  #-----------------------------------------------------------------------------
  # Loads the 'unit' into this unit.
  #-----------------------------------------------------------------------------
  def load(unit)
    # Set flag
    unit.loaded = true
    # Add this unit to the carrying list
    @holding_units.push(unit)
    # Remove the carried unit's sprite (will need to be a different call)
    unit.sprite.dispose #clearly needs to change
  end
  #-----------------------------------------------------------------------------
  # Damages this unit by a certain amount. 'even_damage' will round the damage up
  # to the closest integer (5.2 - 2 = 4.0) (A full 4 HP versus damaged 4 HP)
  # If 'kill' is true, then the damage will destroy the unit.
  #-----------------------------------------------------------------------------
  def injure(amount, even_damage = false, kill = true)
    return if amount <= 0
    # Reduce health
    @health -= amount
    @health = 0 if @health < 0
    if @health == 0
      kill ? destroy : @health = 1
    end
    @health = (@health + 9) / 10 * 10 if even_damage
  end
  #-----------------------------------------------------------------------------
  # Initiates an attack against enemy unit (target)
  # 'type' can be one of these values:
  #   DMG_WINDOW : Gets number to display in the damage window
  #   DMG_RESULT : Gets result of the battle, returning player and enemy damage
  #   DMG_AI     : Used for AI; generalizes damage and factors in next day
  # Returns an array of the amount of damage both parties will do
  #-----------------------------------------------------------------------------
  def fire(type, target, initialized = true, recv_dmg = 0)
    enemy_damage = 0
    # Does enemy unit have counter-first ability?
    if type != DMG_WINDOW && target.is_a?(Unit) and target.co.first_counter and initialized
      # If enemy is a direct combat unit, your unit is direct combat, 
      # and attack can hit
      nearby_units = $game_map.get_nearby_units(target.x,target.y)
      if nearby_units.include?(self) and target.min_range == 1 and 
      target.can_attack?(self)
        # Enemy fires on your unit (self) but did not initialize the attack (false)
        enemy_damage = target.fire(type, self, false)[0]
      end
      # Stop the attack if your unit died by the enemy counter-first attack
      return if self.health - enemy_damage <= 0
      recv_dmg = enemy_damage
    end
    
    # If firing on a structure (pipe-seam, cannon, etc.)
    if target.is_a?(Structure)
      # If can only use secondary weapon
      if @ammo == 0 or target.damage_chart[0][@unit_type] == -1
        damage = target.damage_chart[1][@unit_type] * unit_hp / 10
        @weapon_use = SECONDARY if type == DMG_RESULT
      else # Use primary weapon
        @ammo -= 1 if type == DMG_RESULT
        damage = target.damage_chart[0][@unit_type] * unit_hp / 10
        @weapon_use = PRIMARY if type == DMG_RESULT
      end
      # Get offense boost and apply damage to structure
      damage = damage * offense_power / 100
      return [damage, 0]
    else # Firing on a unit
      # If attack is primary or secondary weapon
      if @ammo == 0 or DamageChart::PriDamage[@unit_type][target.unit_type] == -1
        damage = DamageChart::SecDamage[@unit_type][target.unit_type] * ((self.health - recv_dmg + 9)/10) / 10
        @weapon_use = SECONDARY if type == DMG_RESULT
      else
        @ammo -= 1 if type == DMG_RESULT
        damage = DamageChart::PriDamage[@unit_type][target.unit_type] * ((self.health - recv_dmg + 9)/10) / 10
        @weapon_use = PRIMARY if type == DMG_RESULT
      end
      
      # Damage calculations
      damage  = damage * self.offense_power / 100
      # If doing damage, get randomized luck bonus; else, if calculating for AI,
      # get maximum luck and divide by 2; else, no luck added
      damage += (type == DMG_RESULT ? self.luck_bonus : (type == DMG_AI ? self.luck_bonus(true)/2 : 0))
      damage  = damage * 100 / target.defense_power
      damage  = damage * target.terrain_defense / 100
      # If doing damage, get randomized luck bonus; else, if calculating for AI,
      # get maximum luck and divide by 2; else, no defense luck added
      damage -= (type == DMG_RESULT ? target.def_luck_bonus : (type == DMG_AI ? target.def_luck_bonus(true)/2 : 0))
      
      if type != DMG_WINDOW
        # If last stand and enemy unit has 2HP or more and damage would 
        # destroy it
        if target.is_a?(Unit) and target.co.last_stand and target.unit_hp > 1 and
        target.health - damage <= 0
          # Do enough damage to keep the unit alive with sliver of health
          damage = target.health - 1
        end
      end
    
      if type == DMG_RESULT
        # Adds damage to funds if ability is active
        if co.gain_dmg_as_funds
          dmg = (target.health - damage < 0 ? target.health : damage)
          amt = dmg * target.cost(true) / 100 / 2 # might configure the 2 (KK20)
          @army.funds += amt
        end
      end
      
      if type != DMG_WINDOW
        # Can enemy counter attack?
        if initialized and target.health - damage > 0 && !target.co.first_counter
          # If enemy unit is a direct-combat and is next to your unit
          nearby_units = $game_map.get_nearby_units(target.x,target.y)
          if nearby_units.include?(self) and target.min_range == 1 and 
          target.can_attack?(self)
            # Enemy fires on your unit (self) but did not initialize the attack (false)
            enemy_damage = target.fire(type, self, false, damage)[0]
          end
        end
      end
      
      # Return results of the battle
      return [damage, enemy_damage]
      
    end
  end
  #--------------------------------------------------------------------------
  # Checks the tile at (x,y) to see if it is possible for the unit to move on
  #--------------------------------------------------------------------------
  def passable?(x, y)
    return false if x.nil? or y.nil?
    # return false if coord doesn't exist (out of bounds)
    return false unless $game_map.valid?(x,y)
    # returns false if unit cannot move over terrain
    return false if $game_map.get_tile(x,y).move_cost(self) == 0
    # return false if an enemy unit is on this space
    return false if enemy_unit?(x, y)
    return true
  end
  #--------------------------------------------------------------------------
  # Checks if the unit at (x,y) is an enemy unit; returns true if it is.
  # May also pass in a Unit object instead of coordinates.
  #--------------------------------------------------------------------------
  def enemy_unit?(x, y=nil)
    if x.is_a?(Unit)
      return x.army.team != @army.team
    else
      target_unit = $game_map.get_unit(x,y,false)
      return false if target_unit == nil
      # If not ally
      return target_unit.army.team != @army.team
    end
  end
  #--------------------------------------------------------------------------
  # If this unit is currently visible on the map
  #--------------------------------------------------------------------------
  def exposed?
    # If a unit is moving right now, return the last returned value
    return @exposed if $spriteset.unit_moving
    if @hiding
      # If this unit belongs to the player, the unit is visible
      if @army.playing
        @exposed = true
        return true
      end
      # If the unit is over an enemy property
      tile = $game_map.get_tile(@x, @y)
      if tile.is_a?(Property) and tile.army == $scene.player
        @exposed = true
        return true
      end
      # Get all units surrounding this unit
      nearby_units = $game_map.get_nearby_units(@x, @y)
      # Check if any of the nearby units are an enemy unit. If so, exposed.
      nearby_units.each{|u|
        next unless u.is_a?(Unit)
        if self.enemy_unit?(u)
          @exposed = true
          return true
        end
      }
      # If none of the units nearby were an enemy, this unit is invisible
      @exposed = false
      return false
    end
    # If tile this unit is on is currently covered in darkness
    if $game_map.fow and $spriteset.fow_tilemap.map_data[@x, @y, 0] != 0
      @exposed = false
      return false
    end
    # This unit isn't hiding, so it is obviously visible
    @exposed = true
    return true
  end
  #--------------------------------------------------------------------------
  # Is it possible to attack the unit 'target'? Return true if it is.
  # If target is not specified, returns True if the unit can even Fire.
  #--------------------------------------------------------------------------
  def can_attack?(target=nil)
    # If just checking if this unit can even attack in general
    if target.nil?
      return DamageChart::PriDamage[@unit_type].any?{|dmg| dmg != -1} ||
             DamageChart::SecDamage[@unit_type].any?{|dmg| dmg != -1}
    # If targeting a structure tile
    elsif target.is_a?(Structure)
      if @ammo > 0 and target.damage_chart[0][@unit_type] != -1
        return true
      elsif target.damage_chart[1][@unit_type] != -1
        return true
      else
        return false
      end
      # Targeting a unit
    else
      return false if target.hiding
      if DamageChart::PriDamage[@unit_type][target.unit_type] != -1 and @ammo > 0
        return true
      elsif DamageChart::SecDamage[@unit_type][target.unit_type] != -1
        return true
      else
        return false
      end
    end
  end
  #--------------------------------------------------------------------------
  # Adds a status effect to the unit
  #--------------------------------------------------------------------------
  def add_status_effect(id)
    # Get the status effect from the config
    se = Config.status_effect(id)
    return if se.nil?
    # Add the player turn into the array (now looks like [day,turn,effect,amount,...])
    se.insert(1, $scene.player)
    @status_effects.push(se)
  end
  #--------------------------------------------------------------------------
  # Applies the status effect depending on the type input
  #--------------------------------------------------------------------------
  def get_status_effects(type)
    return 0 if @status_effects.size == 0
    total = 0
    # Run through every status ailment
    @status_effects.each{|se|
      # Locate the string value of 'type' in the array
      i = se.index(type)
      # If unable to locate 'type', next array
      next if i.nil?
      # Gets the amount located directly next to the 'type' and adds to the total
      total += se[i+1]
    }
    return total
  end
  #--------------------------------------------------------------------------
  # Removes status ailments if they have passed their turn limit
  #--------------------------------------------------------------------------
  def update_status_effects
    # Pulls out each individual array
    for i in 0...@status_effects.size
      day = @status_effects[i][0]
      turn = @status_effects[i][1]
      
      # Days counter exists
      if day > 0
        # If the effect that was applied happened during the current player's turn
        if turn == $scene.player
          # Subtract counter
          day -= 1
          # If counter has now hit zero, remove the status effect
          if day == 0
            @status_effects[i] = 0
          else
            @status_effects[i][0] = day
          end
        end
      # Counter started at zero, thus remove this effect
      else
        @status_effects[i] = 0
      end
    end
    # Remove all the empty spots in the array
    @status_effects.delete(0)
  end
  
  #-----------------------------------------------------------------------------
  # What are the limits to this unit's carrying capability? Defined in subclasses.
  #-----------------------------------------------------------------------------
  def carry_capability(unit)
    return false
  end
  #-----------------------------------------------------------------------------
  # Special effects for having units loaded. Defined in subclasses.
  #-----------------------------------------------------------------------------
  def carry_effect
    return false
  end
  #-----------------------------------------------------------------------------
  # Checks if the unit is over a tile that it can drop units off.
  # Defined in subclasses.
  #-----------------------------------------------------------------------------
  def valid_drop_spot(x,y)
    return false
  end
  #-----------------------------------------------------------------------------
  # Checks if the unit can drop off a unit on the tile.
  #-----------------------------------------------------------------------------
  def test_drop_tile(tile, unit)
    return false if unit.nil?
    return tile.move_cost(unit) > 0
  end
end

