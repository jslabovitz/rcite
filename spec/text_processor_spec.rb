require 'spec_helper'

include RCite
include BibTeX

BIB_FILE   = 'spec/files/test.bib'
STYLE_FILE = 'spec/files/valid_style.rb'

describe TextProcessor do

  before :each do
    @pro = TextProcessor.new
    @cmd_processor = @pro.command_processor
    @cmd_processor.load_data(BIB_FILE)
    @cmd_processor.load_style(STYLE_FILE)
  end

  describe '#process_text' do

    it 'should call #process_command for every occurence of #preprocessing_regexp' do
      @pro.stub(:process_command).and_return('cmd')
      text = "%%cite stuff%% %%bib stuff%%"

      @pro.should_receive(:process_command).with('cite stuff')
      @pro.should_receive(:process_command).with('bib stuff')

      @pro.process_text(text).should == 'cmd cmd'
    end

  end # describe #process_text

  describe '#process_command' do

    context 'when the command contains syntax errors' do
      it 'should print an error message but not raise an error' do
        @pro.process_command('cite key key key').should == '%%SYNTAX ERROR%%'
      end
    end

    context 'when YAML fails to parse the hash' do
      it 'should print an error message but not raise an error' do
        YAML.stub('load') do
          raise Psych::SyntaxError
        end
        @pro.process_command('cite key field: value').should
          include('SYNTAX ERROR')
      end
    end

    context 'when no command is specified' do
      it 'should print an error message but not raise an error' do
        @pro.process_command('no_command').should
          include('SYNTAX ERROR')
      end
    end

    context 'when the command description contains a command and an ID' do
      it 'should call @command_processor#command(ID)' do
        @cmd_processor.should_receive(:cite).with('key', {})
        @pro.process_command('cite key')
      end
    end

    context 'when the command description contains additional fields' do
      it 'should turn the additional fields into a hash' do
        @cmd_processor.should_receive(:cite).with('key', {:opt1 => 'val1',
                                                          :opt2 => 'val2' })
        @pro.process_command('cite key opt1: val1, opt2: val2')
      end
    end

    context 'when the command description contains a page number' do
      it 'should turn the page number into a hash element' do
        @cmd_processor.should_receive(:cite).with('key', thepage: '25')
        @pro.process_command('cite key 25')
      end
    end

    context 'when the command description contains both a page number and additional fields' do
      it 'should combine those into a hash' do
        @cmd_processor.should_receive(:cite).with('key', { :thepage => '25'  ,
                                                           :opt1    => 'val1' })
        @pro.process_command('cite key 25 opt1: val1')
      end
    end

    context 'when the command description contains multiple keys' do
      it 'should generate citations/bibliography entries for all of them' do
        @cmd_processor.should_receive(:bib).with('key', { :thepage => '25'  ,
                                                          :opt1    => 'val1' })
        @cmd_processor.should_receive(:bib).with('kez', { :thepage => '33'  ,
                                                          :opt2    => 'val2' })
        @pro.process_command('bib key 25 opt1: val1|kez 33 opt2: val2')
      end
    end

    context 'when the command is a cite command' do

      it 'should add text to each citation according to Style#_around_each_cite' do
        @cmd_processor.stub(:cite).and_return('result')
        @cmd_processor.style._around_each_cite '<begin>', '<end>'
        @pro.process_command('cite key1|key2').should ==
          '<begin>result<end>; <begin>result<end>'
      end

      it 'should add a separator in between citations according to Style#_between_cites' do
        @cmd_processor.style._between_cites '|||'
        @cmd_processor.stub(:cite).and_return('result')
        @pro.process_command('cite key1|key2').should ==
          'result|||result'
      end

      it 'should add additional text as given in Style#_around_all_cites' do
        @cmd_processor.stub(:cite).and_return('result')
        @cmd_processor.style._around_all_cites '<begin>', '<end>'
        @pro.process_command('cite stuff').should == '<begin>result<end>'
      end

    end

    context 'when the command is a bib command' do

      it 'should add text to each bib entry according to Style#_around_each_bib' do
        @cmd_processor.stub(:bib).and_return('result')
        @cmd_processor.style._around_each_bib '<begin>', '<end>'
        @pro.process_command('bib key1|key2').should ==
          "<begin>result<end>\n<begin>result<end>"
      end

      it 'should add a separator in between bib entries according to Style#_between_bibs' do
        @cmd_processor.style._between_bibs '|||'
        @cmd_processor.stub(:bib).and_return('result')
        @pro.process_command('bib key1|key2').should ==
          'result|||result'
      end

      it 'should add additional text as given in Style#_around_all_bibs' do
        @cmd_processor.stub(:bib).and_return('result')
        @cmd_processor.style._around_all_bibs '<begin>', '<end>'
        @pro.process_command('bib stuff')   .should == '<begin>result<end>'
      end

    end

  end # describe #process_command

  describe '#sort_bibliography!' do

    it 'should sort @cited_texts according to the given criteria' do
      txt1 = Entry.new(author: Names.new(Name.new(first: '3rd', last: '4th')),
                       title:  "1st thing")
      txt2 = Entry.new(author: Names.new(Name.new(first: '1st', last: '2nd')),
                       title:  "2nd thing")
      txt3 = Entry.new(author: Names.new(Name.new(first: '1st', last: '2nd')),
                       title:  "1st thing")
      txt4 = Entry.new(author: Names.new(Name.new(first: '5th', last: '6th')),
                       title:  "3rd thing")
      texts = [txt1, txt2, txt3, txt4]
      @cmd_processor.style._sort_bibliography_by [:author, :title]

      @pro.send(:sort_bibliography!, texts) 
      texts.should == [txt3, txt2, txt1, txt4]
    end

    it 'should always sort names by last name first, then by first name' do
      txt1 = Entry.new(author: Names.new(Name.new(first: '1st', last: '2nd')),
                       title:  "1st thing")
      txt2 = Entry.new(author: Names.new(Name.new(first: '2nd', last: '1st')),
                       title:  "1st thing")
      texts = [txt1, txt2]
      @cmd_processor.style._sort_bibliography_by [:author]

      @pro.send(:sort_bibliography!, texts)
      texts.should == [txt2, txt1]
    end

    context 'if an unambiguous order cannot be determined with the given criteria' do
      it 'should fall back to the BibTeX key'  do
        txt1 = Entry.new(author: Names.new(Name.new(first: '1st', last: '2nd')),
                         title:  "1st thing")
        txt1.key = "1"
        txt2 = Entry.new(author: Names.new(Name.new(first: '1st', last: '2nd')),
                         title:  "1st thing")
        txt1.key = "2"
        texts = [txt2, txt1]
        @cmd_processor.style._sort_bibliography_by [:author]

        @pro.send(:sort_bibliography!, texts)
        texts.should == [txt1, txt2]
      end
    end
  end

end # describe FileProcessor
