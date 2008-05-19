require File.dirname(__FILE__) + '/../spec_helper'
require 'mspec/guards/bug'

describe Object, "#ruby_bug" do
  before :each do
    @guard = BugGuard.new "#1234"
    BugGuard.stub!(:new).and_return(@guard)
    ScratchPad.clear
  end

  it "yields when the implementation is not :ruby" do
    @guard.stub!(:implementation?).and_return(false)
    ruby_bug { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "does not yield when the implementation is :ruby" do
    @guard.stub!(:implementation?).and_return(true)
    ruby_bug { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "accepts an optional String identifying the bug tracker number" do
    @guard.stub!(:implementation?).and_return(false)
    ruby_bug("#1234") { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end
end
