require 'spec_helper'
require 'mspec/guards'
require 'mspec/helpers'

describe "#username" do
  before(:all) do
    @ruby_platform = Object.const_get :RUBY_PLATFORM
  end

  after(:all) do
    Object.const_set :RUBY_PLATFORM, @ruby_platform
  end

  it "calls `cmd.exe /C ECHO %USERNAME%` on Windows" do
    PlatformGuard.stub(:windows?).and_return(true)
    ENV.should_receive(:[]).with("USERNAME").and_return("john")
    username
  end

  it "calls `env` on non-Windows" do
    PlatformGuard.stub(:windows?).and_return(false)
    PlatformGuard.stub(:opal?).and_return(false)
    should_receive(:`).with("whoami").and_return("john")
    username
  end

  it "returns the user's username on Windows" do
    PlatformGuard.stub(:windows?).and_return(true)
    ENV.should_receive(:[]).with("USERNAME").and_return("johnonwin")
    username.should == "johnonwin"
  end

  it "returns the user's username on non-Windows, non-Opal platforms" do
    PlatformGuard.stub(:windows?).and_return(false)
    PlatformGuard.stub(:opal?).and_return(false)
    should_receive(:`).with("whoami").and_return("john")
    username.should == "john"
  end
end

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
