require 'facter'
 
begin
  errors = 0
  if ( File.file?("/var/log/kernel.log") )
    File.open("/var/log/kernel.log").each_line do |line|
      begin
        if ( line.chomp =~ /disk.*: I\/O error/ )
          errors = 1
          break
        end
      rescue
      end
    end
  end
  if ( File.file?("/var/log/system.log") )
    File.open("/var/log/system.log").each_line do |line|
      begin
        if ( line.chomp =~ /disk.*: I\/O error/ )
          errors = 1
          break
        end
      rescue
      end
    end
  end
end
 
Facter.add("diskerror") do
  setcode do
    errors
  end
end
