require 'spec_helper'
require 'bibtex'

describe RCite::Style do

  before(:all) do
    @book_entry    = BibTeX::Entry.new {|o| o.type = :book   }
    @article_entry = BibTeX::Entry.new {|o| o.type = :article}
  end

  before(:each) do
    @style = RCite::Style.new
    # The following mocks a concrete style implementation:
    # the user would implement cite_book, cite_article, bib_book etc.
    # methods in order to define how certain types of
    # texts should be cited in a text/footnote and in the
    # bibliography.
    @citation_array = [
      RCite::Element.new(:con, "content1"),
      RCite::Element.new(:sep, "separator"),
      RCite::Element.new(:sep, "separator"),
      RCite::Element.new(:con, "content2"),
    ]
    @style.stub(:cite_book) { @style.elements = @citation_array if @style.text }
    @style.stub(:bib_book)  { @style.elements = @citation_array if @style.text }
  end

  describe '#cite' do
    context "when called for an entry with known type" do
      it "should call the style's method #cite_type and convert the returned "+
        "array of Elements to the corresponding string" do
        @style.cite(@book_entry).should == "content1separatorcontent2"
      end
    end

    context "when the Elements array contains a separator without preceding content" do
      it "should omit the separator" do
        @citation_array = @citation_array[2..3]
        @style.cite(@book_entry).should == "content2"
      end
    end

    context "when the Elements array contains separators without following content" do
      it "should omit the separators" do
        @citation_array = @citation_array[0..2]
        @style.cite(@book_entry).should == "content1"
      end
    end

    context "when the Elements array contains two separators in a row" do
      it "should omit the second one" do
        @citation_array = [
          RCite::Element.new(:con, "content1"),
          RCite::Element.new(:sep, "separator1"),
          RCite::Element.new(:sep, "separator2"),
          RCite::Element.new(:con, "content2"),
        ]
        @style.cite(@book_entry).should == "content1separator1content2"
      end
    end

    context "when called for an entry with unknown type" do
      it "should raise an ArgumentError" do
        expect { @style.cite(@article_entry) }.to raise_exception ArgumentError
      end
    end
  end

  describe '#bib' do
    context "when called for an entry with known type" do
      it "should call the style's method #bib_type" do
        @style.bib(@book_entry).should == 'content1separatorcontent2'
      end
    end

    context "when called for an entry with unknown type" do
      it "should raise an ArgumentError" do
        expect { @style.bib(@article_entry) }.to raise_exception ArgumentError
      end
    end
  end
end
