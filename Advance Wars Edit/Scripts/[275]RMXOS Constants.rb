module RMXOS
  
  GROUP_ADMIN = 10
  GROUP_2NDADMIN = 9
  GROUP_MOD = 8
  GROUP_PLAYER = 0
  
  module Options
    USERPASS_MIN_LENGTH = 3
    USERPASS_MAX_LENGTH = 16
    CHATINPUT_WIDTH = 640
    CHATBOX_WIDTH = 640
    CHATBOX_LINES = 12
    CHATINPUT_MAX_LENGTH = 200
  end
  
  
  
  module Data
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Text constants
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    AvailableCommands     = 'Available Commands:'
    Banned                = 'You are banned from this server.'
    BuddyAlreadyInList    = 'Player already in buddy list.'
    BuddyNotInList        = 'Player not in buddy list.'
    BuddySelfError        = 'You cannot add yourself to your buddy list.'
    Cancel                = 'Cancel'
    CancelingTradeAbort   = 'Canceling... Press CANCEL again to abort trade.'
    Connecting            = 'Connecting...'
    Disconnected          = 'You have been disconnected.'
    EnterUserPass         = 'Enter username and password.'
    ExecutingTrade        = 'Executing trade...'
    Exit                  = 'Exit'
    HelpText              = 'Use /help COMMAND for detailed explanations of a specific command.'
    GuildAlready          = 'You are already in a guild.'
    GuildAlreadyLeader    = 'You are already the guild leader.'
    GuildAlreadyMember    = 'Player is already a member of your guild.'
    GuildCannotLeave      = 'You are the guild leader. You cannot leave the guild unless you transfer leadership to another guild member first.'
    GuildNone             = 'You are not in a guild.'
    GuildNotLeader        = 'You are not the leader of your guild.'
    GuildNotMember        = 'Player is not a member of your guild.'
    GuildNoTransfer       = 'You have not been asked to take over leadership of your guild.'
    GuildReserved         = 'You cannot use this name for a guild.'
    GuildTooLong          = 'Guild name is too long.'
    Kicked                = 'You have been kicked.'
    LoadingMessage        = 'Loading...'
    LoggingIn             = 'Logging in...'
    LoggedIn              = 'Logged in.'
    Login                 = 'Login'
    LoginTimedOut         = 'Login timed out.'
    NoResponse            = 'Server did not respond.'
    NoPMsRetrieved        = 'No PMs were retrieved.'
    NoUsername            = 'Username does not exist.'
    OnlineTag             = ' (ON)'
    PassChar              = '*'
    PassTooShort          = 'Password is too short.'
    PassNotRepeated       = 'The confirmation password does not match!'
    Password              = 'Password:'
    Register              = 'Register'
    Registering           = 'Registering...'
    RegisterUserPass      = 'Register username and password.'
    Repeat                = 'Repeat:'
    SelectServer          = 'Select a server to connect to. Press F5 to refresh the list.'
    ServerOffline         = 'Offline'
    ServerOnline          = 'Online'
    ServerTesting         = 'Testing...'
    Submit                = 'Submit'
    TradeNoPlayer         = 'Your trade partner is gone.'
    TradeSelfError        = 'You cannot trade with yourself.'
    Username              = 'Username:'
    UserRegistered        = 'Username registered!'
    UserRegisteredAlready = 'Username already exists!'
    UserReserved          = 'You cannot use this username.'
    UserTooShort          = 'Username is too short.'
    Version               = 'Version'
    WhisperNoLastName     = 'You first have to use /w once before using /wr.'
    WrongPassword         = 'Wrong password.'
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Special constants
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    BuddyList              = 'Your buddies: BUDDIES'
    GuildInfo              = 'Guild Name: GUILD; Leader: LEADER; Members: MEMBERS'
    PMTooLong              = 'PM is COUNT characters too long.'
    PMInfo                 = 'ID:NUMBER by \'SENDER\' @ TIME'
    PMText                 = '\'SENDER\' @ TIME: MESSAGE'
    TradeWait              = 'Waiting for \'PLAYER\'...'
    ReceivingMessage       = 'Receiving data...'
    ReceivingMessageLegacy = 'Receiving: NOW / MAX'
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Numeric constants
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    CursorBlinkPeriod = 20
    ChatLogSize = 100
    ChatFontHeight = 16
    ChatLineEntries = 50
    ChatBubbleEntries = 8
    ChatBubbleMaxWidth = 192
    BubbleDisplayTime = 5
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Array constants
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    NoTradeItems = [23, 24, 25, 26, 27, 28, 29, 30, 31, 32]
    TradeCommands = ['Select yours', 'View other', 'Confirm', 'Abort']
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Chatbox color constants
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    ColorAction        = Color.new(0xBF, 0xFF, 0xBF)
    ColorError         = Color.new(0xFF, 0xBF, 0x3F)
    ColorGlobal        = Color.new(0x7F, 0xBF, 0xFF)
    ColorGuild         = Color.new(0x1F, 0xFF, 0x7F)
    ColorInfo          = Color.new(0xBF, 0xBF, 0xFF)
    ColorOk            = Color.new(0x1F, 0xFF, 0x1F)
    ColorNo            = Color.new(0x3F, 0x7F, 0xFF)
    ColorNormal        = Color.new(0xFF, 0xFF, 0xFF)
    ColorServerError   = Color.new(0xFF, 0xFF, 0x1F)
    ColorServerOffline = Color.new(0xFF, 0x1F, 0x1F)
    ColorServerOnline  = Color.new(0x1F, 0xFF, 0x1F)
    ColorWhisper       = Color.new(0xFF, 0xFF, 0x1F)
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # Other constants
    #::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    SCREEN_WIDTH = 640
    SCREEN_HEIGHT = 480
    COLORS = {}
    COLORS['self']         = Color.new(0, 255, 0)
    COLORS[GROUP_ADMIN]    = Color.new(64, 192, 255)
    COLORS[GROUP_2NDADMIN] = Color.new(128, 192, 255)
    COLORS[GROUP_MOD]      = Color.new(255, 255, 0)
    COLORS[GROUP_PLAYER]   = Color.new(255, 255, 255)
    COLORS['guild']        = Color.new(255, 192, 0)
    
  end
  
end


class Game_Temp
  
  # setting all accessible variables
  attr_accessor :chat_calling
  attr_accessor :chat_visible
  attr_accessor :chat_active
  attr_accessor :chat_messages
  attr_accessor :chat_logs
  attr_accessor :chat_refresh
  attr_accessor :chat_sprites
  attr_accessor :name_sprites
  attr_accessor :entering_map
  attr_accessor :trade_active
  attr_accessor :trade_host
  attr_accessor :trade_id
  attr_accessor :trade_items
  attr_accessor :trade_abort
  attr_accessor :trade_confirmed
  attr_accessor :trade_canceled
  attr_accessor :trade_cancel_confirmed
  attr_accessor :trade_finalized
  #----------------------------------------------------------------------------
  # Altered to instantiate new variables.
  #----------------------------------------------------------------------------
  alias initialize_rmxos_later initialize
  def initialize
    initialize_rmxos_later
    @chat_calling = false
    @chat_visible = true
    @chat_active = false
    @chat_messages = []
    @chat_logs = []
    @chat_refresh = false
    @chat_sprites = true
    @name_sprites = true
  end
end
