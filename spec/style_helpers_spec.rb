require 'spec_helper'
require 'bibtex'

describe RCite::Style do

  before(:all) do
    @style = RCite::Style.new
  end

  it "should have helper methods for all the BibTeX fields" do
    @style.text = BibTeX::Entry.new({ 'crossref' => 'refme!' })
    @style.crossref.should == 'refme!'
  end

  describe '#initialize' do
    context "when the method #default is defined" do
      it "should merge the hash returned by that method with the builtin default options" do
        class CustomStyle < RCite::Style
          def default
            { :delim => '. ' }
          end
        end

        CustomStyle.new.defaults[:delim].should == '. '
        CustomStyle.new.defaults[:et_al].should == RCite::Style.new.defaults[:et_al]
      end
    end
  end

  describe '#add' do
    before(:each) do
      @style.elements = []
    end

    context "when it is passed any number of strings" do
      it "should convert these strings to Elements and add them to @elements" do
        result = [
          RCite::Element.new(:con, "A string"),
          RCite::Element.new(:con, "AnotherString"),
          RCite::Element.new(:con, " "),
        ]
        @style.add("A string", "AnotherString", " ")
        @style.elements.should == result
      end
    end

    context "when it is passed any number of Elements" do
      it "should add the Elements to @elements" do
        el1 = RCite::Element.new(:con, "A string")
        el2 = RCite::Element.new(:sep, "A seperator")
        el3 = RCite::Element.new(:con, "Another string")
        @style.elements = [ el1 ]
        @style.add(el2, el3)
        @style.elements.should == [ el1, el2, el3 ]
      end
    end

    context "when it is passed an empty string" do
      it "should not add it to @elements" do
        @style.add('')
        @style.elements.should == []
      end
    end
  end

  describe "#sep" do
    it "should return an Element of type :sep with the desired content" do
      @style.sep(', ').should == RCite::Element.new(:sep, ', ')
    end
  end

  describe '#authors' do
    it "should return the text's authors as generated by #authors_or_editors" do
      @style.text = BibTeX::Entry.new(:author => 'Limperg, Jannis')
      @style.authors.should == @style.send(:authors_or_editors,
                                           @style.text[:author].to_names)
    end
  end

  describe '#editors' do
    it "should return the text's editors as generated by #authors_or_editors" do
      @style.text = BibTeX::Entry.new(:editor => 'Limperg, Jannis')
      @style.editors.should == @style.send(:authors_or_editors,
                                           @style.text[:editor].to_names)
    end
  end


  describe '#authors_or_editors' do

    before(:all) do
      @method = :authors_or_editors
    end
    
    before(:each) do
      @list = [
        BibTeX::Name.new(:last => 'Limperg', :prefix => 'von', :first =>
                         'Jannis'),
        BibTeX::Name.new(:last => 'Otto', :first => 'Kai')
      ]
    end
    
    context "when the list contains one person" do
      it "should print that person with the desired ordering" do
        @list = [ @list.first ]
        ordering = :last_first

        @style.send(@method, @list, :ordering => ordering).should ==
          "von Limperg, Jannis"
      end
    end

    context "when the list contains multiple persons with incomplete information" do
      it "should print a correct list anyway" do
        ordering = :last_first
        delim = '; '

        @list[0]['first'] = nil
        @list[1]['first'] = nil
        @style.send(@method, @list, :ordering => ordering, :delim => delim).should ==
          "von Limperg; Otto"
      end
    end

    context "when the list contains multiple persons" do
      it "should print all persons with the desired ordering and delimiter" do
        ordering = :first_last
        delim = "; "

        @style.send(@method, @list, :delim => delim, :ordering => ordering).
          should == "Jannis von Limperg; Kai Otto"
      end
    end

    context "when the list should be shortened by applying 'et al.'" do
      it "should print the desired amount of persons and append 'et al.'" do
        ordering = :last_first
        delim = "; "
        et_al = 1
        et_al_string = "et al."

        @style.send(@method, @list, :delim => delim, :ordering => ordering,
                    :et_al => et_al, :et_al_string => et_al_string).should ==
          "von Limperg, Jannis et al."
      end
    end
  end

  describe '#merge_defaults' do

    before(:all) do
      @method = :merge_defaults
      @style.defaults = { :et_al => 2, :delim => '. ', :ordering => :first_last}
    end

    before(:each) do
      @options = { :delim => ', ', 'ordering' => :last_first }
    end

    context 'when a key is missing in the user-submitted options hash' do
      it "should take it from the defaults hash" do
        @style.send(@method, @options)
        @options[:et_al].should == 2
      end
    end

    context "when a key is present in the user-submitted options hash" do
      it "should supersede the corresponding value from the defaults hash" do
        @style.send(@method, @options)
        @options[:delim].should == ', '
      end
    end

  end

end
