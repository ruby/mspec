require 'mspec/guards/guard'

class PlatformGuard < SpecGuard
  def self.implementation?(*args)
    args.any? do |name|
      case name
      when :rubinius
        RUBY_NAME.start_with?('rbx')
      when :ruby, :jruby, :truffleruby, :ironruby, :macruby, :maglev, :topaz, :opal
        RUBY_NAME.start_with?(name.to_s)
      else
        raise "unknown implementation #{name}"
      end
    end
  end

  def self.standard?
    implementation? :ruby
  end

  HOST_OS = begin
    require 'rbconfig'
    RbConfig::CONFIG['host_os'] || RUBY_PLATFORM
  rescue LoadError
    RUBY_PLATFORM
  end.downcase

  def self.os?(*oses)
    oses.any? do |os|
      HOST_OS.match(os.to_s) ||
        (os == :windows && HOST_OS =~ /(mswin|mingw)/)
    end
  end

  def self.windows?
    os?(:windows)
  end

  def self.platform?(*args)
    args.any? do |platform|
      if platform != :java && RUBY_PLATFORM.include?('java') && os?(platform)
        true
      else
        RUBY_PLATFORM.match(platform.to_s) ||
          (platform == :windows && RUBY_PLATFORM =~ /(mswin|mingw)/)
      end
    end
  end

  def self.wordsize?(size)
    size == 8 * 1.size
  end

  def initialize(*args)
    if args.last.is_a?(Hash)
      @options, @platforms = args.last, args[0..-2]
    else
      @options, @platforms = {}, args
    end
    @parameters = args
  end

  def match?
    match = @platforms.empty? ? true : PlatformGuard.platform?(*@platforms)
    @options.each do |key, value|
      case key
      when :os
        match &&= PlatformGuard.os?(*value)
      when :wordsize
        match &&= PlatformGuard.wordsize? value
      end
    end
    match
  end
end

class Object
  def platform_is(*args)
    g = PlatformGuard.new(*args)
    g.name = :platform_is
    yield if g.yield?
  ensure
    g.unregister
  end

  def platform_is_not(*args)
    g = PlatformGuard.new(*args)
    g.name = :platform_is_not
    yield if g.yield? true
  ensure
    g.unregister
  end
end
