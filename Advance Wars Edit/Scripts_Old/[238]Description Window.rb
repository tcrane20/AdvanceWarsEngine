=begin
___________________________
 Description_Window        \____________________________________________________
 
 Basic window that has two lines to write a short bio. Needed for Unit info and
 later Terrain info.
 
 Notes:
 * 
 
 Updates:
 - XX/XX/XX
________________________________________________________________________________
=end
class Description_Window < Window_Base
  def initialize
    super(58, 400, 522, 72)
    self.contents = Bitmap.new(522, 72)
    self.z = 10000
  end
  
  def draw_info(text)
    self.contents.clear
    draw_text(1, text, true)
  end
  
end
