require 'mspec/matchers/variable'

class HaveInstanceVariableMatcher < VariableMatcher
  def matches?(object)
    @object = object
    @object.instance_variables.include? @variable
  end

  def failure_message
    ["Expected #{@object.inspect} to have instance variable '#{@variable}'",
     "but it does not"]
  end

  def negative_failure_message
    ["Expected #{@object.inspect} NOT to have instance variable '#{@variable}'",
     "but it does"]
  end
end

class Object
  def have_instance_variable(variable)
    HaveInstanceVariableMatcher.new(variable)
  end
end