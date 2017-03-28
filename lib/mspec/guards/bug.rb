require 'mspec/guards/version'

class BugGuard < VersionGuard
  def initialize(bug, version)
    @bug = bug
    if String === version
      @version = SpecVersion.new version, true
    else
      super(version)
    end
    self.parameters = [@bug, @version]
  end

  def match?
    return false if MSpec.mode? :no_ruby_bug
    return false unless standard?
    if Range === @version
      super
    else
      ruby_version <= @version
    end
  end
end

class Object
  def ruby_bug(bug, version)
    g = BugGuard.new bug, version
    g.name = :ruby_bug
    yield if g.yield? true
  ensure
    g.unregister
  end
end
