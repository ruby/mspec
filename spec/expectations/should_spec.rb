require 'spec_helper'
require 'rbconfig'

describe "MSpec" do
  before :all do
    path = RbConfig::CONFIG['bindir']
    exe  = RbConfig::CONFIG['ruby_install_name']
    file = File.dirname(__FILE__) + '/should.rb 2>&1'
    @out = `#{path}/#{exe} #{file}`
  end

  describe "#should" do
    it "records failures" do
      @out.should include <<-EOS
1)
MSpec expectation method #should causes a failure to be recorded FAILED
Expected 1 == 2
to be truthy but was false
EOS
    end

    it "raises exceptions for examples with no expectations" do
      @out.should include <<-EOS
2)
MSpec expectation method #should registers that an expectation has been encountered FAILED
No behavior expectation was found in the example
EOS
    end
  end

  describe "#should_not" do
    it "records failures" do
      @out.should include <<-EOS
3)
MSpec expectation method #should_not causes a failure to be recorded FAILED
Expected 1 == 1
to be falsy but was true
EOS
    end

    it "raises exceptions for examples with no expectations" do
      @out.should include <<-EOS
4)
MSpec expectation method #should_not registers that an expectation has been encountered FAILED
No behavior expectation was found in the example
EOS
    end

    it 'prints a deprecation message about using `{}.should_not raise_error`' do
      @out.should include "Deprecation: ->{}.should_not raise_error breaks code style and is deprecated"
    end
  end

  it "prints status information" do
    @out.should include ".FF..FF."
  end

  it "prints out a summary" do
    @out.should include "0 files, 9 examples, 7 expectations, 4 failures, 0 errors"
  end

  it "records expectations" do
    @out.should include "I was called 7 times"
  end
end
