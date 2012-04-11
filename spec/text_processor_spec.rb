require 'spec_helper'

include RCite

BIB_FILE   = 'spec/files/test.bib'
STYLE_FILE = 'spec/files/valid_style.rb'

describe TextProcessor do

  before :all do
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
    context 'when the command description contains a command and an ID' do
      it 'should call #command_processor#command(ID)' do
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
  end # describe #process_command

end # describe FileProcessor
