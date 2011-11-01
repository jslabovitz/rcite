require 'processor'

describe RCite::Processor do

  VALID_STYLE_FILE = 'files/valid_style.rb'
  WRONG_CLASSNAME_STYLE_FILE = 'files/wrong_classname.rb'
  NO_STYLE_METHODS_STYLE_FILE = 'files/no_methods.rb'

  before(:all) do
    @pro = RCite::Processor.new
  end

  describe '#load_style' do
    context "when called for a valid style-defining file" do
      it "should load the style and make it available in the 'style' instance method" do
        @pro.load_style(VALID_STYLE_FILE)
        @pro.style.class.to_s.should == "RCite::ValidStyle"
      end
    end

    context "when called for a style-defining file where the classname does not match the filename" do
      it "should raise an ArgumentError" do
        expect { @pro.load_style(WRONG_CLASSNAME_STYLE_FILE) }.to raise_error ArgumentError
      end
    end

    context "when called for a style-defining file where the loaded class has no cite and bib methods" do
      it "should raise an ArgumentError" do
        expect { @pro.load_style(NO_STYLE_METHODS_STYLE_FILE) }.to raise_error ArgumentError
      end
    end
  end
end
