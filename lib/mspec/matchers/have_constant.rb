require 'mspec/matchers/variable'

class HaveConstantMatcher < VariableMatcher
  def matches?(mod)
    @mod = mod
    @mod.constants.include? @variable
  end

  def failure_message
    ["Expected #{@mod} to have constant '#{@variable}'",
     "but it does not"]
  end

  def negative_failure_message
    ["Expected #{@mod} NOT to have constant '#{@variable}'",
     "but it does"]
  end
end

class Object
  def have_constant(variable)
    HaveConstantMatcher.new(variable)
  end
end
