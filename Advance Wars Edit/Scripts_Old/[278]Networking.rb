#==============================================================================
# module PointerDerefence
#------------------------------------------------------------------------------
# Provides memory copying.
#==============================================================================

module PointerDerefence

  #----------------------------------------------------------------------------
  # Copies data from a pointer.
  #  length - number of bytes
  # Returns: The copied data.
  #----------------------------------------------------------------------------
  def ref(length)
    buffer = "\0" * length
    Win32API.new('kernel32', 'RtlMoveMemory', 'ppl', '').call(buffer, self, length)
    return buffer
  end
  
end

class Numeric; include PointerDerefence; end;
class String;  include PointerDerefence; end;

#==============================================================================
# module Winsock
#------------------------------------------------------------------------------
# Serves as wrapper for the used Win32API Socket functions.
#==============================================================================

module Winsock

  DLL = 'ws2_32'

  Win32API_bind            = Win32API.new(DLL, 'bind', 'ppl', 'l')
  Win32API_closesocket     = Win32API.new(DLL, 'closesocket', 'p', 'l')
  Win32API_setsockopt      = Win32API.new(DLL, 'setsockopt', 'pllpl', 'l')
  Win32API_connect         = Win32API.new(DLL, 'connect', 'ppl', 'l')
  Win32API_gethostbyname   = Win32API.new(DLL, 'gethostbyname', 'p', 'l')
  Win32API_recv            = Win32API.new(DLL, 'recv', 'ppll', 'l')
  Win32API_select          = Win32API.new(DLL, 'select', 'lpppp', 'l')
  Win32API_send            = Win32API.new(DLL, 'send', 'ppll', 'l')
  Win32API_socket          = Win32API.new(DLL, 'socket', 'lll', 'l')
  Win32API_WSAGetLastError = Win32API.new(DLL, 'WSAGetLastError', '', 'l')
  
  def self.bind(*args);            Win32API_bind.call(*args);            end;
  def self.closesocket(*args);     Win32API_closesocket.call(*args);     end;
  def self.setsockopt(*args);      Win32API_setsockopt.call(*args);      end;
  def self.connect(*args);         Win32API_connect.call(*args);         end;
  def self.gethostbyname(*args);   Win32API_gethostbyname.call(*args);   end;
  def self.recv(*args);            Win32API_recv.call(*args);            end;
  def self.select(*args);          Win32API_select.call(*args);          end;
  def self.send(*args);            Win32API_send.call(*args);            end;
  def self.socket(*args);          Win32API_socket.call(*args);          end;
  def self.WSAGetLastError(*args); Win32API_WSAGetLastError.call(*args); end;
   
end

#==============================================================================
# Socket
#------------------------------------------------------------------------------
# Creates and manages sockets.
#==============================================================================

class Socket

  AF_INET     = 2
  SOCK_STREAM = 1
  SOCK_DGRAM  = 2
  IPPROTO_TCP = 6
  IPPROTO_UDP = 17
  
  # set all accessible variables
  attr_reader :host
  attr_reader :port
  
  #----------------------------------------------------------------------------
  # Returns information about the given hostname.
  #----------------------------------------------------------------------------
  def self.gethostbyname(name)
    data = Winsock.gethostbyname(name)
    raise SocketError::ENOASSOCHOST if data == 0
    host = data.ref(16).unpack('LLssL')
    name = host[0].ref(256).unpack("c*").pack("c*").split("\0")[0]
    address_type = host[2]
    address_list = host[4].ref(4).unpack('L')[0].ref(4).unpack("c*").pack("c*")
    return [name, [], address_type, address_list]
  end
  #----------------------------------------------------------------------------
  # Creates an INET-sockaddr struct.
  #----------------------------------------------------------------------------  
  def self.sockaddr_in(host, port)
    begin
      [AF_INET, port].pack('sn') + gethostbyname(host)[3] + [].pack('x8')
    rescue
    end
  end
  #----------------------------------------------------------------------------
  # Creates a new socket and connects it to the given host and port.
  #----------------------------------------------------------------------------  
  def self.open(*args)
    socket = new(*args)
    if block_given?
      begin
        yield socket
      ensure
        socket.close
      end
    end
    return nil
  end
  #----------------------------------------------------------------------------
  # Creates a new socket.
  #----------------------------------------------------------------------------
  def initialize(domain, type, protocol)
    @descriptor = Winsock.socket(domain, type, protocol)
    SocketError.check if @descriptor == -1
    return @descriptor
  end
  #----------------------------------------------------------------------------
  # Binds a socket to the given sockaddr.
  #----------------------------------------------------------------------------
  def bind(sockaddr)
    result = Winsock.bind(@descriptor, sockaddr, sockaddr.size)
    SocketError.check if result == -1
    return result
  end
  #----------------------------------------------------------------------------
  # Closes a socket.
  #----------------------------------------------------------------------------
  def close
    result = Winsock.closesocket(@descriptor)
    SocketError.check if result == -1
    return result
  end
  #----------------------------------------------------------------------------
  # Connects a socket to the given sockaddr.
  #----------------------------------------------------------------------------
  def connect(host, port)
    @host, @port = host, port
    sockaddr = Socket.sockaddr_in(@host, @port)
    result = Winsock.connect(@descriptor, sockaddr, sockaddr.size)
    SocketError.check if result == -1
    return result
  end
  #----------------------------------------------------------------------------
  # Checks waiting data's status.
  #----------------------------------------------------------------------------
  def select(timeout)
    result = Winsock.select(1, [1, @descriptor].pack('ll'), 0, 0, [timeout, timeout * 1000000].pack('ll'))
    SocketError.check if result == -1
    return result
  end
  #----------------------------------------------------------------------------
  # Checks if data is waiting.
  #----------------------------------------------------------------------------
  def ready?
    return (self.select(0) != 0)
  end  
  #----------------------------------------------------------------------------
  # Returns recieved data.
  #----------------------------------------------------------------------------
  def recv(length, flags = 0)
    buffer = "\0" * length
    result = Winsock.recv(@descriptor, buffer, length, flags)
    SocketError.check if result == -1
    return '' if result == 0
    return buffer[0, result].unpack("c*").pack("c*") # gets rid of a bunch of \0
  end
  #----------------------------------------------------------------------------
  # Sends data to a host.
  #----------------------------------------------------------------------------
  def send(data, flags = 0)
    result = Winsock.send(@descriptor, data, data.size, flags)
    SocketError.check if result == -1
    return result
  end

end

#==============================================================================
# TCPSocket
#------------------------------------------------------------------------------
# Represents a TCP Socket Connection.
#==============================================================================

class TCPSocket < Socket

  #----------------------------------------------------------------------------
  # Initialization.
  #  host - IP or URL of the hots
  #  port - port number
  #----------------------------------------------------------------------------
  def initialize(host = nil, port = nil)
    @messages = []
    @previous_chunk = nil
    
    super(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    self.connect(host, port) if host != nil && port != nil
  end
  
  #--------------------------------------------------------------------------
  # Listens for incoming server messages.
  #--------------------------------------------------------------------------
  def listen
    @messages.clear
    # stop if socket is not ready
    begin
      return if !self.ready?
      # get 0xFFFF bytes from a received message
      buffer = self.recv(0xFFFF)
      # split by \n without suppressing trailing empty strings
      buffer = buffer.split("\n", -1)
      # if chunk from previous incomplete message exists
      if @previous_chunk != nil
        # complete chunk with first new message
        buffer[0] = @previous_chunk + buffer[0]
        # delete chunk buffer
        @previous_chunk = nil
      end
      # remove last message in buffer
      last_chunk = buffer.pop
      # incomplete message if it exists (meaning last message has no \n)
      @previous_chunk = last_chunk if last_chunk != ''
      # check each message in the buffer
      buffer.each {|message|
        interpret_message(message)
      }
    rescue
      msgbox_p "Server closed!"
      self.close
      $close_socket = true
    end
    
  end
  
  
  def interpret_message(msg)
    msgbox_p("Received from server: #{msg}")
    if msg == "DSCN"
      self.close
      $close_socket = true
    end
  end
end

#==============================================================================
# SocketError
#------------------------------------------------------------------------------
# Default exception class for sockets.
#==============================================================================

class SocketError < StandardError
  
  ENOASSOCHOST = 'getaddrinfo: no address associated with hostname.'
  
  def self.check
    errno = Winsock.WSAGetLastError
    raise Errno.const_get(Errno.constants.detect {|c|
      Errno.const_get(c).new.errno == errno}
    )
  end
  
end

class Hangup < Exception
end