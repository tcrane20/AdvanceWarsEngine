class Viewport < Object
  
  def width
    return self.rect.width
  end
  
  def height
    return self.rect.height
  end
  
  alias call_orig_dispose dispose
	def dispose
		@disposed = true
		call_orig_dispose
	end
	
	def disposed?
		return @disposed
	end
	
end
