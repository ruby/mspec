require File.dirname(__FILE__) + '/../spec_helper'
require 'mspec/helpers/tmp'

describe Object, "#tmp" do
  before :all do
    @dir = "#{File.expand_path(Dir.pwd)}/rubyspec_temp"
  end

  it "returns a name relative to the current working directory" do
    tmp("test.txt").should == "#{@dir}/#{SPEC_TEMP_UNIQUIFIER+1}-test.txt"
  end

  it "returns the name of the temporary directory when passed an empty string" do
    tmp("").should == "#{@dir}/"
  end
end
