require 'spec_helper'
require 'mspec/expectations/expectations'
require 'mspec/matchers'
require 'time'

describe SpecPositiveOperatorMatcher, "== operator" do
  it "raises an SpecExpectationNotMetError when expected == actual returns false" do
    lambda {
      SpecPositiveOperatorMatcher.new(1) == 2
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x to equal y'" do
    SpecExpectation.should_receive(:fail_with).with("Expected 1", "to equal 2")
    SpecPositiveOperatorMatcher.new(1) == 2
  end

  it "does not raise an exception when expected == actual returns true" do
    SpecPositiveOperatorMatcher.new(1) == 1
  end
end

describe SpecPositiveOperatorMatcher, "=~ operator" do
  it "raises an SpecExpectationNotMetError when expected =~ actual returns false" do
    lambda {
      SpecPositiveOperatorMatcher.new('real') =~ /fake/
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected \"x\" to match y'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected \"real\"", "to match /fake/")
    SpecPositiveOperatorMatcher.new('real') =~ /fake/
  end

  it "does not raise an exception when expected =~ actual returns true" do
    SpecPositiveOperatorMatcher.new('real') =~ /real/
  end
end

describe SpecPositiveOperatorMatcher, "> operator" do
  it "raises an SpecExpectationNotMetError when expected > actual returns false" do
    lambda {
      SpecPositiveOperatorMatcher.new(4) > 5
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x to be greater than y'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected 4", "to be greater than 5")
    SpecPositiveOperatorMatcher.new(4) > 5
  end

  it "does not raise an exception when expected > actual returns true" do
    SpecPositiveOperatorMatcher.new(5) > 4
  end
end

describe SpecPositiveOperatorMatcher, ">= operator" do
  it "raises an SpecExpectationNotMetError when expected >= actual returns false" do
    lambda {
      SpecPositiveOperatorMatcher.new(4) >= 5
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x to be greater than or equal to y'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected 4", "to be greater than or equal to 5")
    SpecPositiveOperatorMatcher.new(4) >= 5
  end

  it "does not raise an exception when expected > actual returns true" do
    SpecPositiveOperatorMatcher.new(5) >= 4
    SpecPositiveOperatorMatcher.new(5) >= 5
  end
end

describe SpecPositiveOperatorMatcher, "< operater" do
  it "raises an SpecExpectationNotMetError when expected < actual returns false" do
    lambda {
      SpecPositiveOperatorMatcher.new(5) < 4
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x to be less than y'" do
    SpecExpectation.should_receive(:fail_with).with("Expected 5", "to be less than 4")
    SpecPositiveOperatorMatcher.new(5) < 4
  end

  it "does not raise an exception when expected < actual returns true" do
    SpecPositiveOperatorMatcher.new(4) < 5
  end
end

describe SpecPositiveOperatorMatcher, "<= operater" do
  it "raises an SpecExpectationNotMetError when expected < actual returns false" do
    lambda {
      SpecPositiveOperatorMatcher.new(5) <= 4
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x to be less than or equal to y'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected 5", "to be less than or equal to 4")
    SpecPositiveOperatorMatcher.new(5) <= 4
  end

  it "does not raise an exception when expected < actual returns true" do
    SpecPositiveOperatorMatcher.new(4) <= 5
    SpecPositiveOperatorMatcher.new(4) <= 4
  end
end

describe SpecNegativeOperatorMatcher, "== operator" do
  it "raises an SpecExpectationNotMetError when expected == actual returns true" do
    lambda {
      SpecNegativeOperatorMatcher.new(1) == 1
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x not to equal y'" do
    SpecExpectation.should_receive(:fail_with).with("Expected 1", "not to equal 1")
    SpecNegativeOperatorMatcher.new(1) == 1
  end

  it "does not raise an exception when expected == actual returns false" do
    SpecNegativeOperatorMatcher.new(1) == 2
  end
end

describe SpecNegativeOperatorMatcher, "=~ operator" do
  it "raises an SpecExpectationNotMetError when expected =~ actual returns true" do
    lambda {
      SpecNegativeOperatorMatcher.new('real') =~ /real/
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected \"x\" not to match /y/'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected \"real\"", "not to match /real/")
    SpecNegativeOperatorMatcher.new('real') =~ /real/
  end

  it "does not raise an exception when expected =~ actual returns false" do
    SpecNegativeOperatorMatcher.new('real') =~ /fake/
  end
end

describe SpecNegativeOperatorMatcher, "< operator" do
  it "raises an SpecExpectationNotMetError when expected < actual returns true" do
    lambda {
      SpecNegativeOperatorMatcher.new(4) < 5
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x not to be less than y'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected 4", "not to be less than 5")
    SpecNegativeOperatorMatcher.new(4) < 5
  end

  it "does not raise an exception when expected < actual returns false" do
    SpecNegativeOperatorMatcher.new(5) < 4
  end
end

describe SpecNegativeOperatorMatcher, "<= operator" do
  it "raises an SpecExpectationNotMetError when expected <= actual returns true" do
    lambda {
      SpecNegativeOperatorMatcher.new(4) <= 5
    }.should raise_error(SpecExpectationNotMetError)
    lambda {
      SpecNegativeOperatorMatcher.new(5) <= 5
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x not to be less than or equal to y'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected 4", "not to be less than or equal to 5")
    SpecNegativeOperatorMatcher.new(4) <= 5
  end

  it "does not raise an exception when expected <= actual returns false" do
    SpecNegativeOperatorMatcher.new(5) <= 4
  end
end

describe SpecNegativeOperatorMatcher, "> operator" do
  it "raises an SpecExpectationNotMetError when expected > actual returns true" do
    lambda {
      SpecNegativeOperatorMatcher.new(5) > 4
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x not to be greater than y'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected 5", "not to be greater than 4")
    SpecNegativeOperatorMatcher.new(5) > 4
  end

  it "does not raise an exception when expected > actual returns false" do
    SpecNegativeOperatorMatcher.new(4) > 5
  end
end

describe SpecNegativeOperatorMatcher, ">= operator" do
  it "raises an SpecExpectationNotMetError when expected >= actual returns true" do
    lambda {
      SpecNegativeOperatorMatcher.new(5) >= 4
    }.should raise_error(SpecExpectationNotMetError)
    lambda {
      SpecNegativeOperatorMatcher.new(5) >= 5
    }.should raise_error(SpecExpectationNotMetError)
  end

  it "provides a failure message that 'Expected x not to be greater than or equal to y'" do
    SpecExpectation.should_receive(:fail_with).with(
      "Expected 5", "not to be greater than or equal to 4")
    SpecNegativeOperatorMatcher.new(5) >= 4
  end

  it "does not raise an exception when expected >= actual returns false" do
    SpecNegativeOperatorMatcher.new(4) >= 5
  end
end
