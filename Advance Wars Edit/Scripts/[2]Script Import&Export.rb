=begin
================================================================================
Easy Script Importer-Exporter                                       Version 1.0
by KK20                                                             Jun 11 2015
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
  scripts_file = case RGSS
    when 1 then "Scripts.rxdata"
    when 2 then "Scripts.rvdata"
    when 3 then "Scripts.rvdata2"
  end
  # Most likely using a different RGSS version in XP
  if !File.exists?("Data/" + scripts_file)
    scripts_file = "Scripts.rxdata"
  end
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
    
    scripts = load_data("Data/" + scripts_file)
    
    scripts.each_index{|index| 
      script = scripts[index]
      id, name, code = script
      next if id.nil?
      
      name.gsub!("\n") {}
      
      for i in 0...name.size
        name[i] = INVALID_CHAR_REPLACE[name[i].chr] if INVALID_CHAR_REPLACE[name[i].chr]
      end
      
      code = Zlib::Inflate.inflate(code)
      next if SKIP_EMPTY && code.size == 0

      File.open(File.join(FOLDER_NAME, "[#{counter}]#{name}.rb"), "wb") do |f| 
        f.write code
      end
      counter += 1
    }
    
    p "#{counter} files successfully exported."
  end
  
  if IMPORT_EXPORT_MODE == 2
    if RGSS == 3
      a = Dir.entries("Scripts", {:encoding => "UTF-8"})
    else
      a = Dir.entries("Scripts")
    end
    
    a = a[2, a.size]
    f = load_data("Data/" + scripts_file)
    
    if CREATE_SCRIPTS_COPY
      copy = File.open("Data/Copy - " + scripts_file, "wb")
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
      
      z = Zlib::Deflate.new(6)
      data = z.deflate(code, Zlib::FINISH)
      
      f[index] = [index] if f[index].nil?
      f[index][1] = script_name
      f[index][2] = data
    }
    
    data = File.open("Data/" + scripts_file, "wb")
    Marshal.dump(f[0, counter], data)
    data.close
    
    p "#{counter} files successfully imported. Please close your RPG Maker " +
      "now without saving it. Re-open your project to find the scripts imported."
  end
  
  exit
end

end