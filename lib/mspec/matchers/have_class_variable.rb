require 'mspec/matchers/variable'

class HaveClassVariableMatcher < VariableMatcher
  def matches?(mod)
    @mod = mod
    @mod.class_variables.include? @variable
  end

  def failure_message
    ["Expected #{@mod} to have class variable '#{@variable}'",
     "but it does not"]
  end

  def negative_failure_message
    ["Expected #{@mod} NOT to have class variable '#{@variable}'",
     "but it does"]
  end
end

class Object
  def have_class_variable(variable)
    HaveClassVariableMatcher.new(variable)
  end
end