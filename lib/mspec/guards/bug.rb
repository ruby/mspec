require 'mspec/guards/guard'

class BugGuard < SpecGuard
  def initialize(bug)
    @bug = bug
  end

  def match?
    not implementation?(:ruby, :ruby18, :ruby19)
  end
end

class Object
  def ruby_bug(bug="Please add a bug tracker number")
    g = BugGuard.new bug
    yield if g.yield?
    g.unregister
  end
end
