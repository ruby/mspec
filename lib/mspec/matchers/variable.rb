require 'mspec/matchers/stringsymboladapter'

class VariableMatcher
  include StringSymbolAdapter

  def initialize(variable)
    @variable = convert_name(variable)
  end

  def matches?(object)
    raise Exception, "define #matches? in the subclass"
  end
end