class Region
  attr_reader :id, :borders, :bridges
  def initialize(id)
    @id = id
    @prop_count = [0,0,0,0,0,0,0]
    @borders = []
    @bridges = {}
  end
  
  
  def add_border(rid)
    @borders.push(rid) unless @borders.include?(rid)
  end
  
  
  def add_bridge(tile_id, region_id)
    if @bridges[tile_id].nil?
      @bridges[tile_id] = [region_id]
    elsif !@bridges[tile_id].include?(region_id)
      @bridges[tile_id].push(region_id)
    end
  end
    
  
  def size
    total = 0
    @tiletype_count.values.each{|a| total += a}
    return total
  end

end




class RegionPath
  def initialize(dest_reg)
    @region = dest_reg
    @transports = []
  end
end
