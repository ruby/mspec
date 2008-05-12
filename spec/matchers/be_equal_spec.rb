require File.dirname(__FILE__) + '/../spec_helper'
require 'mspec/expectations/expectations'
require 'mspec/matchers/be_equal'

describe BeEqualMatcher do
  it "matches when actual is equal? to expected" do
    BeEqualMatcher.new(1).matches?(1).should == true
    BeEqualMatcher.new(:blue).matches?(:blue).should == true
    BeEqualMatcher.new(Object).matches?(Object).should == true

    o = Object.new
    BeEqualMatcher.new(o).matches?(o).should == true
  end

  it "does not match when actual is not a kind_of? expected" do
    BeEqualMatcher.new(1).matches?(1.0).should == false
    BeEqualMatcher.new(1.5).matches?(1.5).should == false
    BeEqualMatcher.new("blue").matches?("blue").should == false
    BeEqualMatcher.new(Hash).matches?(Object).should == false
  end

  it "provides a useful failure message" do
    matcher = BeEqualMatcher.new("red")
    matcher.matches?("red")
    matcher.failure_message.should == ["Expected \"red\"", "to be identical to \"red\""]
  end

  it "provides a useful negative failure message" do
    matcher = BeEqualMatcher.new(1)
    matcher.matches?(1)
    matcher.negative_failure_message.should == ["Expected 1", "not to be identical to 1"]
  end
end
