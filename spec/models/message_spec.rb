require File.dirname(__FILE__) + '/../spec_helper'

describe Message do

  describe "unconfigured antorcha location" do
    it "should raise configuration error" do
      pending
      lambda { Message.new }.should raise_exception(AntorchaConfigurationMissing)
    end
  end
  
  describe "configured" do
    before(:each) do
      Antorcha.stub :first => mock_antorcha
      mock_antorcha.stub :url => 'http://example.com:4000'
    end

    it "should not raise configuration error" do
      lambda { Message.new }.should_not raise_exception(AntorchaConfigurationMissing)
    end
  end
end
