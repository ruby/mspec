require 'mspec/guards/guard'

# If a spec depends on STDOUT being a tty, use this guard.

class TTYGuard < SpecGuard
  def match?
    STDOUT.tty?
  end
end

class Object
  def with_tty
    g = TTYGuard.new
    g.name = :with_tty
    yield if g.yield?
  ensure
    g.unregister
  end
end
