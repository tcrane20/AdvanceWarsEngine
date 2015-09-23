class Unit
  class Unit_AI
    
    attr_accessor :influence, :capture_list, :base_influence,
    :move_range, :attack_range
    
    def initialize
      @state = nil
      @aggression = nil
      @influence = 0
      @base_influence = 0
      
      @move_range = []
      @attack_range = []
      @capture_list = []
    end
  
    def move_range=(ranges)
      @move_range = ranges if @move_range == []
    end
    
    def attack_range=(ranges)
      @attack_range = ranges if @attack_range == []
    end
    
  end  
end
