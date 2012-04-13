require 'spec_helper'

include RCite

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

    it 'should call #process_command for every occurence of #command_regex' do
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
        @pro.process_command('cite key key key key').should
          include('SYNTAX ERROR')
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

      it 'should add text to each citation according to Style#around(:each, :cite)' do
        @cmd_processor.stub(:cite).and_return('result')
        @cmd_processor.style.around(:each, :cite, '<begin>', '<end>')
        @pro.process_command('cite key1|key2').should ==
          '<begin>result<end>; <begin>result<end>'
      end

      it 'should add a separator in between citations according to Style#between(:cites)' do
        @cmd_processor.style.between(:cites, '|||')
        @cmd_processor.stub(:cite).and_return('result')
        @pro.process_command('cite key1|key2').should ==
          'result|||result'
      end

      it 'should add additional text as given in Style#around(:all, :cites)' do
        @cmd_processor.stub(:cite).and_return('result')
        @cmd_processor.style.around(:all, :cites, '<begin>', '<end>')
        @pro.process_command('cite stuff').should == '<begin>result<end>'
      end

    end

    context 'when the command is a bib command' do

      it 'should add text to each bib entry according to Style#around(:each, :bib)' do
        @cmd_processor.stub(:bib).and_return('result')
        @cmd_processor.style.around(:each, :bib, '<begin>', '<end>')
        @pro.process_command('bib key1|key2').should ==
          "<begin>result<end>\n<begin>result<end>"
      end

      it 'should add a separator in between bib entries according to Style#between(:bibs)' do
        @cmd_processor.style.between(:bibs, '|||')
        @cmd_processor.stub(:bib).and_return('result')
        @pro.process_command('bib key1|key2').should ==
          'result|||result'
      end

      it 'should add additional text as given in Style#around(:all, :bibs)' do
        @cmd_processor.stub(:bib).and_return('result')
        @cmd_processor.style.around(:all, :bibs, '<begin>', '<end>')
        @pro.process_command('bib stuff')   .should == '<begin>result<end>'
      end

    end

  end # describe #process_command

end # describe FileProcessor
