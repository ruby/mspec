require 'mspec/guards/platform'

class SupportedGuard < SpecGuard
  def match?
    if @parameters.include? :ruby
      raise Exception, "improper use of not_supported_on guard"
    end
    PlatformGuard.standard? or !PlatformGuard.implementation?(*@parameters)
  end
end

class Object
  def not_supported_on(*args)
    g = SupportedGuard.new(*args)
    g.name = :not_supported_on
    yield if g.yield?
  ensure
    g.unregister
  end
end
