require 'style.rb'

class UserStyle < RCite::Style 
  def cite_book(text)
    'book cited!'
  end

  def bib_book(text)
    'book bib\'d!'
  end
end

describe RCite::Style do

  before(:all) do
    @style = UserStyle.new
    
    @book_entry = {:type => :book}
    @article_entry = {:type => :article}
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
