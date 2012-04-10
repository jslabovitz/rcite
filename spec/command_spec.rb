require 'spec_helper'

include RCite::CLI

describe Command do

  before :each do
    @slop = Slop.new
    Command.any_instance.stub(:setup_slop).and_return(@slop)
    @command = Command.new
    @command.instance_variable_set('@slop', @slop)
  end

  describe '#help' do
    it 'should return @slop.help' do
      @slop.stub(:help).and_return("help string")
      @command.help.should == "help string"
    end
  end # describe #help

  describe '#run' do

    it 'should parse the command line options' do
      @command.stub('run!')
      @slop.should_receive(:parse!)
      @command.run([])
    end

    it 'should run the command' do
      @command.stub('run!')
      @command.should_receive(:run!)
      @command.run([])
    end

    context 'when any mandatory options are missing' do
      it 'should log an error and exit' do
        @slop.on :req, :r, '', required: true
        log.should_receive(:error)
        expect { @command.run([]) }.to raise_error(SystemExit)
      end
    end
  end

end # describe class Command
