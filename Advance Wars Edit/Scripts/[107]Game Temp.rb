class Game_Temp
  attr_accessor :moveto_locations
  
  alias more_temp_vars initialize
  def initialize
    more_temp_vars
    @disable_officertag = false
    @disable_infowindow = false
    @disable_player = false
    @moveto_locations = []
  end
end
