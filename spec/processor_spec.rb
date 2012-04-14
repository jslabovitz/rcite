require 'spec_helper'

describe RCite::Processor do

  VALID_STYLE_FILE  = 'spec/files/valid_style.rb'
  VALID_STYLE_FILE2 = 'spec/files/valid_style2.rb'
  VALID_BIB_FILE    = 'spec/files/all_types.bib'

  before(:all) do
    @pro = RCite::Processor.new
  end

  describe '#load_style' do
    it 'should create a new style class and load the given file into it' do
      @pro.load_style(VALID_STYLE_FILE)
      fail 'Style class is undefined' unless defined? @pro.style_class
      sty = @pro.style
      sty.should_not be(nil)
      sty.respond_to?(:cite_book, true).should == true
      sty.respond_to?(:bib_book,  true).should == true
    end

    it 'should create a different style class every time it runs' do
      @pro.load_style(VALID_STYLE_FILE)
      c1 = @pro.style_class
      @pro.load_style(VALID_STYLE_FILE)
      c2 = @pro.style_class
      c1.to_s.should_not == c2.to_s
    end

    it 'should unload the old style completely' do
      @pro.load_style(VALID_STYLE_FILE2)
      @pro.load_style(VALID_STYLE_FILE)
      @pro.style.respond_to?(:additional_method, true).should == false 
    end

    context 'if the given file cannot be loaded' do
      it 'should raise a LoadError' do
        expect { @pro.load_style('inexistant_file')  }.to raise_error LoadError
      end
    end
  end

  describe '#load_data' do
    it "should load bibliography data as BibTeX::Bibliography#open does" do
      @pro.load_data(VALID_BIB_FILE)
      @pro.bibliography['article1']['title'].should == "Ein Artikel"
    end
  end

  BIB_HASH = BibTeX::Bibliography.new do |bib|
    bib << BibTeX::Entry.new(:key => 'article1', :type => 'article')
  end
  ELEMENTS = [
    RCite::Element.new(:con, "something"),
    RCite::Element.new(:sep, "somesep"),
    RCite::Element.new(:con, "someotherthing"),
  ]

  describe '#cite' do

    before(:each) do
      @pro.bibliography = BIB_HASH
      @pro.style = RCite::Style.new
      @pro.style.stub(:cite_article) { @pro.style.elements = ELEMENTS }
    end

    context "when the style and bib attributes are set correctly and a valid id is given" do
      it "should generate a citation based on the current style" do
        @pro.cite('article1').should == "somethingsomesepsomeotherthing"
      end
    end

    context "when the style and bib attributes are set correctly but an invalid id is given" do
      it "should raise an ArgumentError" do
        expect { @pro.cite(:book1) }.to raise_error ArgumentError
      end
    end

    context "when either of the style and bib attributes are nil" do
      it "should raise an ArgumentError" do
        @pro.bibliography = nil
        expect { @pro.cite(:article1) }.to raise_error ArgumentError

        @pro.bibliography = BIB_HASH
        @pro.style = nil
        expect { @pro.cite(:article1) }.to raise_error ArgumentError
      end
    end
  end

  describe '#bib' do

    before(:each) do
      @pro.bibliography = BIB_HASH
      @pro.style = RCite::Style.new
      @pro.style.stub(:bib_article) { @pro.style.elements = ELEMENTS }
    end

    context "when the style and bib attributes are set correctly and a valid id is given" do
      it "should generate a bibliography entry based on the current style" do
        @pro.bib(:article1).should == 'somethingsomesepsomeotherthing'
      end
    end

    context "when the style and bib attributes are set correctly but an invalid id is given" do
      it "should raise an ArgumentError" do
        expect { @pro.bib(:book1) }.to raise_error ArgumentError
      end
    end

    context "when either of the style and bib attributes are nil" do
      it "should raise an ArgumentError" do
        @pro.bibliography = nil
        expect { @pro.bib(:article1) }.to raise_error ArgumentError

        @pro.bibliography = BIB_HASH
        @pro.style = nil
        expect { @pro.bib(:article1) }.to raise_error ArgumentError
      end
    end
  end

end
