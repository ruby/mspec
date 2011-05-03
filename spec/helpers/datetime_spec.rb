require File.dirname(__FILE__) + '/../spec_helper'
require 'date'
require 'mspec/helpers/hash'

describe Object, "#new_datetime" do
  it "returns a default date time" do
    new_datetime.should == DateTime.new
  end

  it "takes an empty hash for the default" do
    new_datetime({}).should == DateTime.new
  end

  it "takes a hash with an attribute" do
    d = new_datetime :second => 2
    d.second.should == 2
  end
end
