require 'mspec/guards/guard'

class Object
  def home_directory
    if PlatformGuard.windows?
      path = ENV['HOMEDRIVE'] + ENV['HOMEPATH']
      path.tr('\\', '/').chomp('/')
    else
      ENV['HOME']
    end
  end

  def hostname
    commands = ['hostname', 'uname -n']
    commands.each do |command|
      name = ''
      platform_is_not :opal do
        name = `#{command}`
      end
      return name.strip if $?.success?
    end
    raise Exception, "hostname: unable to find a working command"
  end
end
