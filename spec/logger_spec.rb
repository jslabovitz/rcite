require 'spec_helper'

describe RCite::Logger do

  before :each do
    @log = RCite::Logger.instance
  end

  it 'should have the programme name set to "rcite"' do
    @log.progname.should == 'rcite'
  end

  it 'should have a nice formatting' do
    @log.formatter.call('ERROR', nil, 'rcite', 'msg').should ==
      "rcite ERROR: msg\n"
  end

  describe '::instance' do
    context 'if @@instance is not nil' do
      it 'should return @@instance' do
        RCite::Logger.class_variable_set(:@@instance, 'instance')
        RCite::Logger.instance.should == 'instance'
      end
    end

    context 'if @@instance is nil' do
      it 'should return a new logger' do
        RCite::Logger.class_variable_set(:@@instance, nil)
        RCite::Logger.instance.class.should == RCite::Logger
      end
    end
  end # describe ::instance

  describe '#ex' do
    it 'should log an error message that includes the exception\'s message' do
      ex = Exception.new('ex_message')
      ex.set_backtrace([])
      @log.stub(:error) { |msg| msg.include?('halleluja') }
      @log.should_receive(:error).and_return('blub')
      @log.ex(ex)
    end
  end # describe #ex

end # describe RCite::Logger

describe '::log' do
  it 'should return RCite::Logger::instance' do
    log.should == RCite::Logger.instance
  end
end # describe ::log
