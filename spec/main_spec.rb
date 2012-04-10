require 'spec_helper'

class RCite::CLI::TestCommand < RCite::CLI::Command
  def self.name
    'stuff'
  end

  def run!
    'run ran'
  end

  def setup_slop
    @slop = Slop.new
  end
end

include RCite::CLI

describe Main do

  describe '::run' do

    context 'if no command is given' do
      it 'should raise an error' do
        log.should_receive(:error)
        Main.run([''])
      end
    end

    context 'if a command is given' do

      context 'and there is a corresponding Command subclass' do
        it 'should call the Command subclass\'s #run method' do
          TestCommand.any_instance.should_receive(:run)
          Main.run(['stuff'])
        end
      end

      context 'and there is no corresponding Command subclass' do
        it 'should log an error' do
          log.should_receive(:error)
          Main.run(['unknown_command'])
        end
      end

    end

  end # describe ::run

end # describe Main
