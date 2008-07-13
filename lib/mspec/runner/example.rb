require 'mspec/runner/mspec'

# Holds some of the state of the example (i.e. +it+ block) that is
# being evaluated. See also +ContextState+.
class ExampleState
  attr_reader :describe, :it, :example

  def initialize(describe, it, example=nil)
    @describe   = describe
    @it         = it
    @example    = example
    @unfiltered = nil
  end

  def description
    @description ||= "#{@describe} #{@it}"
  end

  def unfiltered?
    unless @unfiltered
      incl = MSpec.retrieve(:include) || []
      excl = MSpec.retrieve(:exclude) || []
      @unfiltered   = incl.empty? || incl.any? { |f| f === description }
      @unfiltered &&= excl.empty? || !excl.any? { |f| f === description }
    end
    @unfiltered
  end

  def filtered?
    not unfiltered?
  end
end
