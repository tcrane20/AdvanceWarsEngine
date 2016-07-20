=begin
_____________
 Army        \__________________________________________________________________
 
 Essentially for each player, an instace is created. Holds all the necessary
 things related to the player including CO, funds, units, properties owned,
 CO power charged, conditional flags, and team.
 
 Notes:
 * Clean up needed
 
 Updates:
 - 11/02/14
   + <charge_power> from Unit has been moved into this class
   + Daily repair costs no longer use floats
________________________________________________________________________________
=end
# Defines each player
class Army
  attr_accessor :id
  attr_accessor :x, :y
  attr_accessor :team
  attr_accessor :owned_props
  attr_accessor :units
  attr_accessor :funds
  attr_accessor :officer
  attr_accessor :nation
  attr_accessor :stored_energy
  attr_accessor :recharge_rate
  attr_accessor :can_rout
  attr_accessor :lost_battle
  attr_accessor :halve_income
  attr_accessor :cost_per_frame
  attr_reader   :repair_amount
  attr_accessor :reduced_terrain_stars
  attr_accessor :playing
  
  def initialize(id, team, officer = nil)
    @id = id
    @x = 0
    @y = 0
    @team = team
    @owned_props = []
    @units = []
    @funds = 0
    @stored_energy = 0
    @recharge_rate = 100
    officer = "nil" if officer == nil
    ####
    temp = officer.split
    officer = temp.join
    ####
    @officer = eval("CO_#{officer}.new(self)")
    @nation = get_nation
    @can_rout = false
    @lost_battle = false
    @halve_income = false
    @reduced_terrain_stars = 0
    
    # If it is currently this army's turn
    @playing = false
  end
  
  def get_nation
    return case @officer.description[0]
    when "Orange Star" then 1
    when "Blue Moon" then 2
    when "Green Earth" then 3
    when "Yellow Comet" then 4
    when "Black Hole" then 5
    else
      0
    end
  end
  
  def funds=(amt)
    @funds = amt.to_i
    @funds = 999999 if @funds > 999999
  end
  
  def add_unit(unit)
    @units.push(unit)
    @can_rout = true
  end
  
  def cleanup_units
    @units.compact!
    @lost_battle = 1 if @units.size == 0 && @can_rout
  end
  
  
  #----------------------------------------------------------------------------
  # Ensures that the maximum charge can only go up to the officer's max power
  #----------------------------------------------------------------------------
  def stored_energy=(amt)
    return if (@officer.cop or @officer.scop)
    @stored_energy = amt
    @stored_energy = @officer.scop_rate if @stored_energy >= @officer.scop_rate
    @stored_energy = 0 if @stored_energy < 0
  end
  
  def daily_income
    cities = []
    @owned_props.each{|prop| cities.push(prop) unless prop.is_a?(ComTower)}
    # If earning half income this turn
    return (cities.size * 10 * @officer.income_multiplier)
  end
  
  def earn_daily_income
    amount = daily_income
    # If earning half income this turn
    if @halve_income
      self.funds += amount / 2
      @halve_income = false
    else
      self.funds += amount
    end
  end
  
  #----------------------------------------------------------------------------
  # Controls the daily repair process and calculations.
  # Returns the number of frames to process repair animations.
  #----------------------------------------------------------------------------
  def daily_repair(unit, building=nil)
    # Determine how much HP will be repaired this turn
    @repair_amount =  [10 - unit.unit_hp, @officer.repair].min
    frames = 0
    # How much money will this cost to repair this unit X HP
    if @repair_amount == 0
      @repair_amount = 1 # To heal the chip damage of the 10HP unit
      repair_cost = 0
    else
      repair_cost = (unit.cost(true) * @repair_amount) / 10
    end
    # How many frames should this repair animation take
    case repair_cost
    when 0..1000
      frames = 20
    when 1001..3000
      frames = 30
    when 3001..5000
      frames = 40
    when 5001..999999
      frames = 80
    end
    # Reduce player funds by this amount each frame to create rolling numbers
    @target_funds = @funds - repair_cost
    @cost_per_frame = repair_cost / frames
    # Make the first frame funds reduction
    frame_repair
    return frames
  end
  #----------------------------------------------------------------------------
  # Reduces funds each frame based on @cost_per_frame value.
  # This method is called after 'daily_repair' in the main scene class.
  # It essentially creates a 'rolling numbers' effect on the player's funds.
  # 'last' is TRUE if this is the last frame of deducting funds.
  #----------------------------------------------------------------------------
  def frame_repair(last=false)
    if last
      @funds = @target_funds
    else
      @funds -= @cost_per_frame
    end
  end
  #----------------------------------------------------------------------------
  # Returns how many properties of a certain type the army owns
  #----------------------------------------------------------------------------
  def num_of_property(prop_class)
    return @owned_props.count{|prop| prop.is_a?(prop_class)}
  end
  
  #----------------------------------------------------------------------------
  # If the player can use a CO power
  #----------------------------------------------------------------------------
  def can_use_power?
    return (@stored_energy >= @officer.cop_rate and @officer.cop_stars != 0)
  end
  #----------------------------------------------------------------------------
  # If the player can use a Super CO Power
  #----------------------------------------------------------------------------
  def can_use_super?
    return @stored_energy == @officer.scop_rate
  end
  #----------------------------------------------------------------------------
  # Uses CO Powers. If scop is true, using a Super CO Power.
  #----------------------------------------------------------------------------
  def use_power(scop = false)
    if scop
      @officer.use_scop
      @stored_energy = 0
    else
      @officer.use_cop
      @stored_energy -= @officer.cop_rate + (100 - 2 * (100 - @recharge_rate))
      @stored_energy = 0 if @stored_energy < 0
    end
    # The more you use powers, the slower it fills up
    @recharge_rate -= 5
    @recharge_rate = 50 if @recharge_rate < 50
  end
  #----------------------------------------------------------------------------
  # Returns true if a COP or SCOP is being used. False otherwise.
  #----------------------------------------------------------------------------
  def using_power?
    return (@officer.cop or @officer.scop)
  end
  #----------------------------------------------------------------------------
  # Stores cursor (x,y)
  #----------------------------------------------------------------------------
  def set_cursor(x,y)
    @x = x
    @y = y
  end
  #-----------------------------------------------------------------------------
  # Charges up the CO's power bar. 
  # 'amount' refers to damage done.
  # 'unit' is the one being targetted for damage.
  # 'multiplier' refers to how much of the damage is added to power bar
  #-----------------------------------------------------------------------------
  def charge_power(unit, amount, multiplier)
    # Play the "power ready" sound if amount is less than COP/SCOP limits
    play_power_se = (@stored_energy < @officer.cop_rate and @officer.cop_stars != 0)
    play_spower_se = (@stored_energy != @officer.scop_rate)
    
    # Calculate damage, amount of energy, and add result to officer power bar
    damage = (unit.health - amount < 0 ? unit.health : amount)
    multiplier += 20 if (!@playing and damage >= 50) # bonus charge for high damage received
    amt = damage * unit.star_energy / 100
    self.stored_energy += (amt * multiplier * @recharge_rate) / 10000

    # Play the sound effect if the conditions have been met
    if @playing
      if play_spower_se and @stored_energy == @officer.scop_rate
        Config.play_se("superpower")
      elsif play_power_se and @stored_energy >= @officer.cop_rate
        Config.play_se("power")
      end
    end
  end
  
end
