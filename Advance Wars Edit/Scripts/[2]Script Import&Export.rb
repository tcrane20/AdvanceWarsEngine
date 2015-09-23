=begin
================================================================================
Easy Script Importer-Exporter                                       Version 1.2
by KK20                                                             Jun 22 2015
--------------------------------------------------------------------------------

[ Introduction ]++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Ever wanted to export your RPG Maker scripts to .rb files, make changes to
  them in another text editor, and then import them back into your project?
  Look no further, fellow scripters. ESIE is easy to use!
  
[ Instructions ]++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Place this script at the top of your script list to ensure it runs first.
  Make any changes to the configuration variables below if desired.
  Run your game and a message box will prompt success and close the game.
  
  If exporting, you can find the folder containing a bunch of .rb files in your
  project folder. Please do not remove the "[###]" in the filename as this is
  used to ensure the scripts are loaded back into the project in the correct
  order.
  
  If importing, please close your project (DO NOT SAVE IT) and re-open it.
  
[ Compatibility ]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  This script already has methods to ensure it will run properly on any RPG
  Maker version. This script does not rely on nor makes changes to any existing
  scripts, so it is 100% compatible with anything.
  
[ Credits ]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  KK20 - made this script
  GubiD - referenced his VXA Script Import/Export
  FiXato and HIRATA Yasuyuki - referenced VX/VXA Script Exporter
  ForeverZer0 - suggesting and using Win32API to read .ini file

================================================================================
=end

#******************************************************************************
# B E G I N   C O N F I G U R A T I O N
#******************************************************************************
#------------------------------------------------------------------------------
# Set the script's mode. Will export the scripts, import the scripts, or do
# absolutely nothing.
#       ACCEPTED VALUES:
#       0 = Disable (pretends like this script doesn't even exist)
#       1 = Export
#       2 = Import
#       3 = Playtest (import scripts from folder to playtest game; does not
#                     replace or create a 'Scripts.r_data' file)
#------------------------------------------------------------------------------
IMPORT_EXPORT_MODE = 1
#------------------------------------------------------------------------------
# Folder name where scripts are imported from and exported to
#------------------------------------------------------------------------------
FOLDER_NAME = "Scripts"
#------------------------------------------------------------------------------
# If true, will ignore creating files for scripts that have no code in them.
# Turning this to false is helpful if you like to categorize your script list
# for easier viewing. Useless for importing.
#------------------------------------------------------------------------------
SKIP_EMPTY = false
#------------------------------------------------------------------------------
# Will delete all files in the folder prior to exporting. Recommended to stay
# true unless you know what you're doing. Useless for importing.
#------------------------------------------------------------------------------
DELETE_OLD_CONTENTS = true
#------------------------------------------------------------------------------
# Creates a duplicate of the Scripts.r_data file to ensure you don't break your
# project. The duplicate will be placed in the Data folder as "Copy - Scripts".
# Recommended to stay true. Useless for exporting.
#------------------------------------------------------------------------------
CREATE_SCRIPTS_COPY = true
#------------------------------------------------------------------------------
# If true, converts any instances of tab characters (\t) into two spaces. This
# is extremely helpful if writing code from an external editor and moving it
# back into RPG Maker where tab characters are instantly treated as two spaces.
#------------------------------------------------------------------------------
TABS_TO_SPACES = true
#******************************************************************************
# E N D   C O N F I G U R A T I O N
#******************************************************************************
#------------------------------------------------------------------------------
if IMPORT_EXPORT_MODE != 0

RGSS = (RUBY_VERSION == "1.9.2" ? 3 : defined?(Hangup) ? 1 : 2)

if RGSS == 3
  def p(*args)
    msgbox_p args
  end
end

# From GubiD's script
INVALID_CHAR_REPLACE = {
  "\\"=> "&",
  "/" => "&",
  ":" => ";",
  "*" => "#",
  "?" => "!",
  "<" => "[",
  ">" => "]",
  "|" => "¦",
  "\""=> "\'"
}

begin
  ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
  scripts_filename = "\0" * 256
  ini.call('Game', 'Scripts', '', scripts_filename, 256, '.\\Game.ini')
  scripts_filename.delete!("\0")
  
  counter = 0
  
  if IMPORT_EXPORT_MODE == 1
    
    if DELETE_OLD_CONTENTS && File.exists?(FOLDER_NAME)
      if RGSS == 3
        files = Dir.entries(FOLDER_NAME, {:encoding => "UTF-8"})
      else 
        files = Dir.entries(FOLDER_NAME)
      end
      
      files[2, files.size].each do |filename|
        File.delete(FOLDER_NAME + "/" + filename)
      end
    end
    
    Dir.mkdir(FOLDER_NAME) unless File.exists?(FOLDER_NAME)
    
    scripts = load_data(scripts_filename)
    
    scripts.each_index{|index| 
      script = scripts[index]
      id, name, code = script
      next if id.nil?
      
      for i in 0...name.size
        name[i] = INVALID_CHAR_REPLACE[name[i].chr] if INVALID_CHAR_REPLACE[name[i].chr]
      end
      
      code = Zlib::Inflate.inflate(code)
      next if SKIP_EMPTY && code.size == 0
      code.gsub!(/\t/) {'  '} if TABS_TO_SPACES
      
      File.open(File.join(FOLDER_NAME, "[#{counter}]#{name}.rb"), "wb") do |f| 
        f.write code
      end
      counter += 1
    }
    
    p "#{counter} files successfully exported."
    exit
  end
  
  if IMPORT_EXPORT_MODE >= 2
    if RGSS == 3
      a = Dir.entries("Scripts", {:encoding => "UTF-8"})
    else
      a = Dir.entries("Scripts")
    end
    
    a = a[2, a.size]
    if IMPORT_EXPORT_MODE == 2
      scripts_file = File.open(scripts_filename, "rb")
      f = Marshal.load(scripts_file)
    else
      f = $RGSS_SCRIPTS
    end
    
    if IMPORT_EXPORT_MODE == 2 && CREATE_SCRIPTS_COPY
      base_name = File.basename(scripts_filename)
      dir_name = File.dirname(scripts_filename)
      copy = File.open(dir_name + "/Copy - " + base_name, "wb")
      Marshal.dump(f, copy)
      copy.close
    end
    
    a.each{|filename|
      counter += 1
      script = File.open("Scripts/" + filename, "r+")
      index = filename.gsub(/\[(\d+)\].*/) {$1}
      index = index.to_i
      script_name = filename.gsub(/\[\d+\](.*)\.rb/) { $1 }
      code = script.read
      code.gsub!(/\t/) {'  '} if TABS_TO_SPACES
      
      if IMPORT_EXPORT_MODE == 2
        z = Zlib::Deflate.new(6)
        data = z.deflate(code, Zlib::FINISH)
      else
        data = code
      end
      
      f[index] = [index] if f[index].nil?
      f[index][1] = script_name
      f[index][IMPORT_EXPORT_MODE] = data
    }
    
    if IMPORT_EXPORT_MODE == 2
      data = File.open(scripts_filename, "wb")
      Marshal.dump(f[0, counter], data)
      data.close
      p "#{counter} files successfully imported. Please close your RPG Maker " +
      "now without saving it. Re-open your project to find the scripts imported."
      exit
    end
  end
  
end

end