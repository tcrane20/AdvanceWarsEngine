class RPG::Map
  attr_accessor :army_setup, :lose_conditions, :team_lose, :army_colors
  
  def number_of_players
    count = 0
    @army_setup.each{|item| count += 1 if item != 0}
    return count
  end
  
  def initialized?
    return ![@army_setup, @lose_conditions, @team_lose, @army_colors].delete(nil).nil?
  end
  
end
