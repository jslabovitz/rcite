require 'spec_helper'

describe RCite::Element do

  before(:all) do
    @ele = RCite::Element.new(:con, "content")
  end

  describe '#type=' do
    context "when passed an invalid type" do
      it "should raise an error" do
        expect { @ele.type = :invalid_type }.to raise_error
      end
    end

    context "when passed a valid type" do
      it "should set the 'type' instance variable accordingly" do
        @ele.type = :con
        @ele.type.should == :con
        @ele.type = :sep
        @ele.type.should == :sep
      end
    end
  end

  describe '#content=' do
    it "should set the 'content' instance variable with a string representation"+
      "of the parameter" do
      @ele.content = 123
      @ele.content.should == "123"
    end
  end

  describe '#==' do
    context "if type and content are equal" do
      it "should return true" do
        RCite::Element.new(:con, "s").should == RCite::Element.new(:con, "s")
      end
    end

    context "if type and content are not equal" do
      it "should return false" do
        RCite::Element.new(:sep, "s").should_not ==
        RCite::Element.new(:con, "s")
        RCite::Element.new(:con, "ss").should_not ==
        RCite::Element.new(:con, "s")
      end
    end
  end

  describe '#to_s' do
    it "should return a string representation of the element" do
      fail if ! @ele.to_s.is_a? String
    end
  end
end
