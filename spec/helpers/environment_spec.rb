require 'spec_helper'
require 'mspec/guards'
require 'mspec/helpers'

describe "dev_null" do
  it "returns 'NUL' on Windows" do
    PlatformGuard.should_receive(:windows?).and_return(true)
    dev_null().should == "NUL"
  end

  it "returns '/dev/null' on non-Windows" do
    PlatformGuard.should_receive(:windows?).and_return(false)
    dev_null().should == "/dev/null"
  end
end
