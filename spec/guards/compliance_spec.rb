require File.dirname(__FILE__) + '/../spec_helper'
require 'mspec/guards/compliance'

describe Object, "#compliant_on" do
  before :each do
    ScratchPad.clear

    @guard = CompliantOnGuard.new
    CompliantOnGuard.stub!(:new).and_return(@guard)

    @guard.stub!(:standard?).and_return(false)
    @guard.stub!(:implementation?).and_return(false)
    @guard.stub!(:platform?).and_return(false)
  end

  it "does not yield when #standard?, #implementation? and #platform? return false" do
    compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "yields when #standard? returns true" do
    @guard.should_receive(:standard?).and_return(true)
    compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "yields when #implementation? returns true" do
    @guard.should_receive(:implementation?).and_return(true)
    compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "yields when #platform? return true" do
    @guard.should_receive(:platform?).and_return(true)
    compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "yields when #standard?, #implementation? and #platform? return true" do
    @guard.stub!(:standard?).and_return(true)
    @guard.stub!(:implementation?).and_return(true)
    @guard.stub!(:platform?).and_return(true)
    compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end
end

describe Object, "#not_compliant_on" do
  before :each do
    ScratchPad.clear

    @guard = NotCompliantOnGuard.new
    NotCompliantOnGuard.stub!(:new).and_return(@guard)

    @guard.stub!(:standard?).and_return(false)
  end

  it "yields when #standard? returns true" do
    @guard.should_receive(:standard?).and_return(true)
    @guard.stub!(:implementation?).and_return(true)
    @guard.stub!(:platform?).and_return(true)
    not_compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "does not yield when #implementation? and #platform? return true" do
    @guard.stub!(:implementation?).and_return(true)
    @guard.stub!(:platform?).and_return(true)
    not_compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "does not yield when #implementation? or #platform? return true" do
    @guard.stub!(:implementation?).and_return(true)
    @guard.stub!(:platform?).and_return(false)
    not_compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield

    @guard.stub!(:implementation?).and_return(false)
    @guard.stub!(:platform?).and_return(true)
    not_compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "yields when #implementation? and #platform? return false" do
    @guard.stub!(:implementation?).and_return(false)
    @guard.stub!(:platform?).and_return(false)
    not_compliant_on(:rbx) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end
end
