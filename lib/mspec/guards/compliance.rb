require 'mspec/guards/guard'

class CompliantOnGuard < SpecGuard
  def match?
    standard? or implementation?(*@args)
  end
end

class NotCompliantOnGuard < SpecGuard
  def match?
    standard? or !implementation?(*@args)
  end
end

class Object
  def compliant_on(*args)
    g = CompliantOnGuard.new(*args)
    g.name = :compliant_on
    yield if g.yield?
  ensure
    g.unregister
  end

  def not_compliant_on(*args)
    g = NotCompliantOnGuard.new(*args)
    g.name = :not_compliant_on
    yield if g.yield?
  ensure
    g.unregister
  end
end
