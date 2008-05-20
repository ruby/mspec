require File.dirname(__FILE__) + '/../spec_helper'
require 'mspec/guards/version'

# These specs are very "brittle" and must be updated to
# precisely those values that are expected for each of
# the versions supported.
#
#   :standard - This (with rare exceptions) is the
#   stable version of Ruby at ruby-lang.org
#
#   :development - This is the next version of Ruby
#   in the same minor version as "standard" Ruby
#
#   :experimental - This is currently version 1.9

describe Object, "#ruby_version_is :standard" do
  before :all do
    @verbose = $VERBOSE
    $VERBOSE = nil
  end

  after :all do
    $VERBOSE = @verbose
  end

  before :each do
    @ruby_version = Object.const_get :RUBY_VERSION
    @ruby_patch = Object.const_get :RUBY_PATCHLEVEL

    @guard = VersionGuard.new :standard
    VersionGuard.stub!(:new).and_return(@guard)
    ScratchPad.clear
  end

  after :each do
    Object.const_set :RUBY_VERSION, @ruby_version
    Object.const_set :RUBY_PATCHLEVEL, @ruby_patch
  end

  it "yields when RUBY_VERSION == '1.8.6', RUBY_PATCHLEVEL == 114" do
    Object.const_set :RUBY_VERSION, '1.8.6'
    Object.const_set :RUBY_PATCHLEVEL, 114

    ruby_version_is(:standard) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "does not yield when RUBY_VERSION != '1.8.6'" do
    Object.const_set :RUBY_VERSION, '1.8.5'
    Object.const_set :RUBY_PATCHLEVEL, 114

    ruby_version_is(:standard) { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "does not yield when RUBY_PATCHLEVEL != 114" do
    Object.const_set :RUBY_VERSION, '1.8.6'
    Object.const_set :RUBY_PATCHLEVEL, 111

    ruby_version_is(:standard) { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "yields if any arg is :standard when RUBY_VERSION == '1.8.6', RUBY_PATCHLEVEL == 114" do
    Object.const_set :RUBY_VERSION, '1.8.6'
    Object.const_set :RUBY_PATCHLEVEL, 114

    @guard = VersionGuard.new :extra, :standard, :nonstandard
    VersionGuard.stub!(:new).and_return(@guard)

    ruby_version_is(:standard) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end
end

describe Object, "#ruby_version_is :development" do
  before :all do
    @verbose = $VERBOSE
    $VERBOSE = nil
  end

  after :all do
    $VERBOSE = @verbose
  end

  before :each do
    @ruby_version = Object.const_get :RUBY_VERSION

    @guard = VersionGuard.new :development
    VersionGuard.stub!(:new).and_return(@guard)
    ScratchPad.clear
  end

  after :each do
    Object.const_set :RUBY_VERSION, @ruby_version
  end

  it "yields when RUBY_VERSION == '1.8.7'" do
    Object.const_set :RUBY_VERSION, '1.8.7'

    ruby_version_is(:development) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "does not yield when RUBY_VERSION != '1.8.7'" do
    Object.const_set :RUBY_VERSION, '1.8.6'

    ruby_version_is(:development) { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "yields if any arg is :development when RUBY_VERSION == '1.8.7'" do
    Object.const_set :RUBY_VERSION, '1.8.7'

    @guard = VersionGuard.new :extra, :development, :standard
    VersionGuard.stub!(:new).and_return(@guard)

    ruby_version_is(:standard) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end
end

describe Object, "#ruby_version_is :experimental" do
  before :all do
    @verbose = $VERBOSE
    $VERBOSE = nil
  end

  after :all do
    $VERBOSE = @verbose
  end

  before :each do
    @ruby_version = Object.const_get :RUBY_VERSION

    @guard = VersionGuard.new :experimental
    VersionGuard.stub!(:new).and_return(@guard)
    ScratchPad.clear
  end

  after :each do
    Object.const_set :RUBY_VERSION, @ruby_version
  end

  it "yields when RUBY_VERSION == '1.9.0'" do
    Object.const_set :RUBY_VERSION, '1.9.0'

    ruby_version_is(:experimental) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end

  it "does not yield when RUBY_VERSION != '1.9.0'" do
    Object.const_set :RUBY_VERSION, '1.8.7'

    ruby_version_is(:experimental) { ScratchPad.record :yield }
    ScratchPad.recorded.should_not == :yield
  end

  it "yields if any arg is :development when RUBY_VERSION == '1.9.0'" do
    Object.const_set :RUBY_VERSION, '1.9.0'

    @guard = VersionGuard.new :extra, :experimental, :standard
    VersionGuard.stub!(:new).and_return(@guard)

    ruby_version_is(:experimental) { ScratchPad.record :yield }
    ScratchPad.recorded.should == :yield
  end
end
