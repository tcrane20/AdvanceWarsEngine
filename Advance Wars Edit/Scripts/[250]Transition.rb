# Currently does a basic transition
class Transition
  
  def initialize
    $TRANSITION = self
    @bl_box = Sprite.new
    @tr_box = Sprite.new
    blackbox = Bitmap.new(640,480)
    blackbox.fill_rect(0,0,640,480, Color.new(0,0,0))
    @bl_box.bitmap = blackbox
    @tr_box.bitmap = blackbox
    @bl_box.x = -640
    @bl_box.y = 480
    @bl_box.z = 99999
    @tr_box.x = 640
    @tr_box.y = -480
    @tr_box.z = 99999
    @frame = 0
  end
  
  def update
   #p @frame
    if @frame < 30
      @bl_box.x += 21
      @bl_box.y -= 16
      @tr_box.x -= 21
      @tr_box.y += 16
    elsif @frame >= 80
      dispose
    elsif @frame > 45
      @bl_box.x -= 21
      @bl_box.y += 16
      @tr_box.x += 21
      @tr_box.y -= 16
    end
    @frame += 1
  end
  
  def dispose
    $TRANSITION = nil
    @bl_box.bitmap.dispose
    @bl_box.dispose
    @tr_box.dispose
  end
  
end
