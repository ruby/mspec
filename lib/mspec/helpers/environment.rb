require 'mspec/guards/guard'

class Object
  def env
    env = nil

    platform_is_not :opal, :windows do
      env = Hash[*`env`.split("\n").map { |e| e.split("=", 2) }.flatten]
    end

    platform_is :windows do
      env = Hash[*`cmd.exe /C set`.split("\n").map { |e| e.split("=", 2) }.flatten]
    end

    platform_is :opal do
      env = {}
    end

    env
  end

  def windows_env_echo(var)
    platform_is_not :opal do
      `cmd.exe /C ECHO %#{var}%`.strip
    end
  end

  def username
    user = ""

    platform_is :windows do
      user = windows_env_echo('USERNAME')
    end

    platform_is_not :opal do
      user = `whoami`.strip
    end

    user
  end

  def home_directory
    return ENV['HOME'] unless PlatformGuard.windows?
    windows_env_echo('HOMEDRIVE') + windows_env_echo('HOMEPATH')
  end

  def dev_null
    if PlatformGuard.windows?
      "NUL"
    else
      "/dev/null"
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
