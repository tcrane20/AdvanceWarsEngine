# Updates message windows no matter where you are at
module Graphics
  class << self
    alias update_for_messages update
    def update
      update_for_messages
      $MESSAGES.each{|msg| msg.update}
      $TRANSITION.update unless $TRANSITION.nil?
    end
  end
end
