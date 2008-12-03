require File.dirname(__FILE__) + '/../spec_helper'
require 'mspec/helpers/fixture'

describe Object, "#fixture" do
  it "returns the expanded path to a fixture file" do
    dir = File.expand_path(Dir.pwd)
    name = fixture("some/path/file.rb", "dir", "file.txt")
    name.should == "#{dir}/some/path/fixtures/dir/file.txt"
  end
end
