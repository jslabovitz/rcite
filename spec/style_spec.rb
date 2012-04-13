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

  end # describe #cite

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

  end # describe #bib

  describe '#around(quantifier, command, before_string, after_string)' do

    context 'if either of the two keys is invalid' do
      it 'should raise an ArgumentError' do
        expect { @style.around(:every, :bib, '', '') }.to
          raise_error ArgumentError
        expect { @style.around(:all, :citez, '', '') }.to
          raise_error ArgumentError
      end
    end

    context 'if either of the two strings is nil' do
      it 'should not change the associated value' do
        @style.around(:all, :cites, :changes, :remains)
        @style.around(:all, :cites, :changed, nil     )

        @style.around(:all, :cites).should == [:changed, :remains]
      end
    end

  end # describe #around 1

  describe '#around(quantifier, command)' do
    it 'should return the same results for :bib/:bibs and :cite/:cites' do
      o1, o2 = Object.new, Object.new
      @style.around(:all, :bibs,  o1, o2)
      @style.around(:all, :cites, o2, o1)

      @style.around(:all, :bib ).should == [o1, o2]
      @style.around(:all, :cite).should == [o2, o1]
    end
  end # describe #around 2
end
