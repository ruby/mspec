require 'mspec/guards/version'

class BugGuard < VersionGuard
  def initialize(bug, version)
    @bug = bug
    @version = SpecVersion.new version, true
  end

  def match?
    return false if MSpec.mode? :no_ruby_bug
    standard? && ruby_version <= @version
  end
end

class Object
  def ruby_bug(bug, version)
    g = BugGuard.new bug, version
    yield if g.yield? true
    g.unregister
  end
end
