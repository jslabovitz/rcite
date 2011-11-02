require 'style'
require 'rspec/mocks'

describe RCite::Style do

  before(:all) do
    @book_entry = {:type => :book}
    @article_entry = {:type => :article}
  end

  before(:each) do
    @style = RCite::Style.new
    # The following mocks a concrete style implementation:
    # the user would implement cite_book, cite_article, bib_book etc.
    # methods in order to define how certain types of
    # texts should be cited in a text/footnote and in the
    # bibliography.
    @style.stub(:cite_book) { $tmp = 'book cited!' if $text }
    @style.stub(:bib_book) { $tmp = 'book bib\'d!' if $text }
  end

  describe '#cite' do
    context "when called for an entry with known type" do
      it "should call the style's method #cite_type" do
        @style.cite(@book_entry).should == 'book cited!'
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
        @style.bib(@book_entry).should == 'book bib\'d!'
      end
    end

    context "when called for an entry with unknown type" do
      it "should raise an ArgumentError" do
        expect { @style.bib(@article_entry) }.to raise_exception ArgumentError
      end
    end
  end
end
