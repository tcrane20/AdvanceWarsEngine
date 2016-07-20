################################################################################
# Class Hachi
#   Army: Orange Star           Power Bar: x x x X X
#
# - 90% Deployment costs
#
# Power: Barter
# - 50% Deployment costs
#
# Super Power: Merchant Union
# - Units may be bought from cities
#   
################################################################################
class CO_Hachi < CO
  def initialize(army=nil)
    super(army)
    @name = "Hachi"
    @cop_name = "Barter"
    @scop_name = "Merchant Union"
    @description = [
    "Orange Star", "Tea", "Medicine",
    "The former commander-in-chief of Orange Star who now owns a store. He likes to relax more so than fight nowadays.",
    "Knows secret trade routes, allowing him to purchase units for cheap.",
    "Makes deals with other merchants to buy units at half their normal cost.",
      "Unites merchants everywhere to allow land units to be built in cities.",
    "Retired commander of Orange Star. Purchases units for lower prices. Powers improve his buying capabilities and allow him to build units on cities."]
    @cop_stars = 4
    @scop_stars = 5
    @cost_multiplier = 90
  end
  
  def use_cop
    super
    @cost_multiplier = 50
  end
  
  def use_scop
    super
    @build_on_cities = true
  end
  #========================
  # Turning off COP effects
  #========================
  def cop=(bool)
    if !bool
      @cost_multiplier = 90
    end
    @cop = bool
  end
  #========================
  # Turning off SCOP effects
  #========================
  def scop=(bool)
    if !bool
      @build_on_cities = false
    end
    @scop = bool
  end
  
end
$CO.push(CO_Hachi)