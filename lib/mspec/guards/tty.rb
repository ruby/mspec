require 'mspec/guards/guard'

# Some specs will block if run under as subprocess where STDOUT is not a TTY.
# For most specs, there is probably a way to provide an IOStub that could
# pretend to be a TTY. See the IOStub helper. That helper needs combined with
# the output_to_fd helper.

class TTYGuard < SpecGuard
  def match?
    STDOUT.tty?
  end
end

class Object
  def with_tty
    g = TTYGuard.new
    yield if g.yield?
    g.unregister
  end
end
