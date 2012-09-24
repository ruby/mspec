require 'spec_helper'
require 'mspec/guards'

describe Object, "#with_block_device" do
  before :each do
    ScratchPad.clear

    @guard = BlockDeviceGuard.new
    BlockDeviceGuard.stub!(:new).and_return(@guard)
  end

  it "yields if block device is available" do
    @guard.should_receive(:`).and_return("block devices")
    with_block_device { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "does not yield if block device is not available" do
    @guard.should_receive(:`).and_return(nil)
    with_block_device { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "sets the name of the guard to :with_block_device" do
    with_block_device { }
    @guard.name.should == :with_block_device
  end

  it "calls #unregister even when an exception is raised in the guard block" do
    @guard.should_receive(:match?).and_return(true)
    @guard.should_receive(:unregister)
    lambda do
      with_block_device { raise Exception }
    end.should raise_error(Exception)
  end
end
