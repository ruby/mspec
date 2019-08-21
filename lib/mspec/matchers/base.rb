module MSpecMatchers
end

class MSpecEnv
  include MSpecMatchers
end

# Expectations are sometimes used in a module body
class Module
  include MSpecMatchers
end

class SpecPositiveOperatorMatcher
  def initialize(actual)
    @actual = actual
  end

  def ==(expected)
    unless @actual == expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "to equal #{MSpec.format(expected)}")
    end
  end

  def <(expected)
    unless @actual < expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "to be less than #{MSpec.format(expected)}")
    end
  end

  def <=(expected)
    unless @actual <= expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "to be less than or equal to #{MSpec.format(expected)}")
    end
  end

  def >(expected)
    unless @actual > expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "to be greater than #{MSpec.format(expected)}")
    end
  end

  def >=(expected)
    unless @actual >= expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "to be greater than or equal to #{MSpec.format(expected)}")
    end
  end

  def =~(expected)
    unless @actual =~ expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "to match #{MSpec.format(expected)}")
    end
  end
end

class SpecNegativeOperatorMatcher
  def initialize(actual)
    @actual = actual
  end

  def ==(expected)
    if @actual == expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "not to equal #{MSpec.format(expected)}")
    end
  end

  def <(expected)
    if @actual < expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "not to be less than #{MSpec.format(expected)}")
    end
  end

  def <=(expected)
    if @actual <= expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "not to be less than or equal to #{MSpec.format(expected)}")
    end
  end

  def >(expected)
    if @actual > expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "not to be greater than #{MSpec.format(expected)}")
    end
  end

  def >=(expected)
    if @actual >= expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "not to be greater than or equal to #{MSpec.format(expected)}")
    end
  end

  def =~(expected)
    if @actual =~ expected
      SpecExpectation.fail_with("Expected #{MSpec.format(@actual)}",
                            "not to match #{MSpec.format(expected)}")
    end
  end
end
