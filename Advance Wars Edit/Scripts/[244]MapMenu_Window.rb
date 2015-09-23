class MapMenu_Window < Window_Command
  
  def initialize(army)
    # Populate the commands
    commands = []
    commands.push("Cancel")
    commands.push("CO")
    commands.push("Power") if army.can_use_power? and !army.using_power?
    commands.push("Super Power") if army.can_use_super?
    commands.push("End Turn")
    # Create window
    super(200, commands, true)
    self.z = 10000
    # Move the window
    set_at(220, 100)
    
  end
  
  
  
end
