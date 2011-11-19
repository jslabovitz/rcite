require 'spec_helper'
require 'processor'
require 'style'
require 'style_helpers'
require 'rspec/mocks'

describe RCite::Processor do

  VALID_STYLE_FILE = 'spec/files/valid_style.rb'
  WRONG_CLASSNAME_STYLE_FILE = 'spec/files/wrong_classname.rb'
  NO_STYLE_METHODS_STYLE_FILE = 'spec/files/no_methods.rb'
  VALID_BIB_FILE = 'spec/files/all_types.bib'

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

  describe '#load_data' do
    it "should load bibliography data as BibTeX::Bibliography#open does" do
      @pro.load_data(VALID_BIB_FILE)
      @pro.bibliography['article1']['title'].should == "Ein Artikel"
    end
  end

  BIB_HASH = [{'id' => 'article1', 'type' => 'article'}]

  describe '#cite' do

    before(:each) do
      @pro.bibliography = BIB_HASH
      @pro.style = RCite::Style.new
      @pro.style.stub(:cite_article) { $tmp = "Article cited!" }
      BIB_HASH.stub(:to_citeproc) { BIB_HASH }
    end

    after(:each) do
      $tmp = nil
    end

    context "when the style and bib attributes are set correctly and a valid id is given" do
      it "should generate a citation based on the current style" do
        @pro.cite('article1').should == "Article cited!"
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
      BIB_HASH.stub(:to_citeproc) { BIB_HASH }
      @pro.bibliography = BIB_HASH
      @pro.style = RCite::Style.new
      @pro.style.stub(:bib_article) { $tmp = "Article bib\'d!" }
    end

    after(:each) do
      $tmp = nil
    end

    context "when the style and bib attributes are set correctly and a valid id is given" do
      it "should generate a bibliography entry based on the current style" do
        @pro.bib(:article1).should == "Article bib\'d!"
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
