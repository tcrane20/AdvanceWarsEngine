class Array2D
	def initialize(width, height, init = nil)
    @width = width
    @height = height
		@data = Array.new(width) { Array.new(height, init) }
	end
	def [](*args)
    if args.size == 2
      # If passed arguments go beyond the size of the 2D Array
      if args[0] < 0 || args[0] >= @width || args[1] < 0 || args[1] >= @height
        return Object
      else
        return @data[args[0]][args[1]]
      end
    else
      @data[args[0]]
    end
	end
	def []=(*args)
		args.size == 3 ? @data[args[0]][args[1]] = args[2] : @data[args[0]] = args[1] 
	end
  # Smashes the 2D array into 1D array, for better evaluation
  def flatten
    return @data.flatten
  end
  
  def each_index
    for i in 0...@data.size
      yield i
    end
  end
  
  def each
    for i in 0...@data.size
      yield @data[i]
    end
  end
  
end

