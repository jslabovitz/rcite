require 'style'
require 'style_helpers'

describe RCite::Style do

  before(:all) do
    @style = RCite::Style.new
  end

  it "should have helper methods for all the BibTeX fields" do
    $text = { :crossref => 'refme!' }
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
        CustomStyle.new.defaults[:et_al].should == 3
      end
    end
  end

  describe '#add' do
    after(:each) do
      $tmp = nil
    end

    context "when it is passed any number of strings" do
      it "should add these strings to the $tmp global variable" do
        @style.add("A string", "AnotherString", " ")
        $tmp.should == "A stringAnotherString "
      end
    end

    context "when the first value it is passed is nil or an empty string" do
      it "should return without doing anything" do
        @style.add(nil, "a string", "another string")
        @style.add('', 'yet another string')
        $tmp.should == nil
      end
    end
  end

  describe '#year' do
    it "should return the year in which the current text was published" do
      text = {
        :id => 'book1',
        :issued => { 'date-parts' => [[2011,3]] }
      }
      $text = text
      @style.year.should == "2011"
    end
  end

  describe '#month' do
    it "should return the month in which the current text was published" do
      text = {
        :id => 'book1',
        :issued => { 'date-parts' => [[2011,3]] }
      }
      $text = text
      @style.month.should == "3"
    end
  end

  describe '#authors_or_editors' do

    before(:all) do
      @method = :authors_or_editors
    end
    
    before(:each) do
      @list = [
        { :family => 'Limperg', :dropping_particle => 'von', :given => 'Jannis' },
        { :family => 'Otto', :given => 'Kai' }
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

        @list[0][:given] = nil
        @list[1][:given] = nil
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
