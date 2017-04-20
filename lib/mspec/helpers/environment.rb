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
end
