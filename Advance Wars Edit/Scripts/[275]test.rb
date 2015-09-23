=begin
  s = TCPSocket.new('127.0.0.1', 54269)
  
  s.send("Testing\n")
   
  while true
    Graphics.update
    Input.update
    
    s.listen
    
    if (Input.trigger?(Input::C))
      s.send("UACT 3 5 2442 1 8 FIRE\n")
    elsif Input.trigger?(Input::B)
      break
    end
    
  end
  
  p "Broke"
  s.close
  
  exit
=end
#--------------------------------------------------------------------------
# Tests the connection capability to a host.
#  host  - IP address or URL (as string)
#  port  - port for connection
#  index - index for simultanous tests
# Returns: Whether a connection could be astablished or not.
#--------------------------------------------------------------------------
def test_connection(host, port)
  begin
    # try to create a socket
    socket = TCPSocket.new(host, port)
    # try to send something
    socket.send("HAI\n")
    # try to close the socket
    socket.close
    # connection works
    return true
  rescue Hangup
    # cease further testing
    return nil
  rescue
    msgbox_p "rescue"
  ensure
    # make sure socket is closed
    socket.close rescue nil
  end
  # connection failed
  return false
end
#-----------------------------------------------------------------------------

module NoDeactivateDLL
  Start = Win32API.new("NoDeactivate", "Start", '', '')
  InFocus = Win32API.new("NoDeactivate", "InFocus", '', 'i')
end

module Input
  class << self
    alias update_again update
  end
  
  def self.update
    update_again if NoDeactivateDLL::InFocus.call() == 1
  end
end

NoDeactivateDLL::Start.call()

#-----------------------------------------------------------------------------

begin
  Graphics.resize_screen(640,480)
  $game_temp = Game_Temp.new
  # socket
  @s = nil
  # chat window
  @chatinput_window = Frame_ChatInput.new
  @chat_window = Frame_Chat.new
  @chatinput_window.active = true
  @chat_window.active = true
  server_started = false
  
  while true
    Graphics.update
    Input.update
    # update chat
    @chatinput_window.update
    @chat_window.update
    
    @s.listen if !@s.nil?
    
    if $close_socket == true
      @s = nil
    end
    
    $close_socket = false

    if Input.trigger?(Input::SHIFT) && !server_started
      system('start CServer.exe')
      server_started = true
    elsif Input.trigger?(Input::L)
      result = test_connection('127.0.0.1', 54269)
      msgbox_p "Failed to connect" if !result
    elsif Input.trigger?(Input::R)
      @s = TCPSocket.new('127.0.0.1', 54269)
    elsif Input.trigger?(Input::C)
      @s.send("Testing\n")
    elsif Input.trigger?(Input::B)
      @s.close
      break
    end

  end
  exit
end
