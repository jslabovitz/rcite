require 'spec_helper'
require 'slop'

include RCite::CLI

VALID_STYLE = File.join('spec', 'files', 'valid_style.rb')
VALID_BIB   = File.join('spec', 'files', 'test.bib'      )

# SHARED EXAMPLES ##############################################################

shared_examples 'cite_bib' do |command_class, command_name|

  describe '#run!' do
    context 'if the given text ID is undefined' do
      it 'should log an error and exit' do
        log.should_receive(:error).once

        expect { @cmd.run(['-s', VALID_STYLE,
                           '-b', VALID_BIB  ,
                           'undefined_id'     ]) }.
          to raise_error SystemExit
      end
    end
  end # describe #run!

end # shared examples cite_bib

shared_examples 'all_commands' do |command_class, command_name|

  before :each do
    @cmd = command_class.send(:new)
  end

  describe '::name' do
    it 'should return the command\'s name' do
      command_class.name.should == command_name
    end
  end # describe ::name
  
  describe '#setup_slop' do
    it 'should set up some slop options' do
      @cmd.instance_variable_set(:@slop, nil)
      @cmd.setup_slop
      @cmd.instance_variable_get(:@slop).class.should == Slop
    end
  end # describe #setup_slop

  describe '#validate_opts' do

    context 'if any of style, bibliography or text ID/file is not specified' do
      it 'should log an error and exit' do

        log.should_receive(:error).exactly(3).times

        expect { @cmd.run(['-s', VALID_STYLE, 'butcher-81']) }.
          to raise_error SystemExit
        expect { @cmd.run(['-b', VALID_BIB  , 'butcher-81']) }.
          to raise_error SystemExit
        expect { @cmd.run(['-s', VALID_STYLE,
                           '-b', VALID_BIB                ]) }.
          to raise_error SystemExit
      end
    end

    context 'if the given style file does not exist' do
      it 'should log an error and exit' do
        log.should_receive(:error).once

        expect { @cmd.run(['-s', 'style/file/does/not/exist',
                           '-b', VALID_BIB                  ,
                           'butcher-81'                       ]) }.
          to raise_error SystemExit
      end
    end

    context 'if the given bibliography file does not exist' do
      it 'should log an error and exit' do
        log.should_receive(:error).once

        expect { @cmd.run(['-s', VALID_STYLE                ,
                           '-b', 'bib/file/does/not/exist'  ,
                           'butcher-81'                       ]) }.
          to raise_error SystemExit
      end
    end

  end # describe #validate_opts

end # shared examples all commands

# CiteCommand ##################################################################

describe CiteCommand do

  before :each do
    @cmd = CiteCommand.new
  end

  include_examples 'all_commands', CiteCommand, 'cite'
  include_examples 'cite_bib'    , CiteCommand, 'cite'

  describe '#run!' do
    it 'should cite the specified text ID' do
      @cmd.run(['-s', VALID_STYLE,
                '-b', VALID_BIB  ,
                'butcher-81'      ]).should == 'citation: Butcher, Judith 1981'

    end
  end # describe #run!

end # describe CiteCommand

# BibCommand ###################################################################

describe BibCommand do

  before :each do
    @cmd = BibCommand.new
  end

  include_examples 'all_commands', BibCommand, 'bib'
  include_examples 'cite_bib'    , BibCommand, 'bib'

  describe '#run!' do
    it 'should create a bibliography entry for the specified text ID' do

      @cmd.run(['-s', VALID_STYLE,
                '-b', VALID_BIB  ,
                'butcher-81'      ]).should == 'bibentry: Butcher, Judith 1981'
    end
  end # describe #run!

end # describe BibCommand

# ProcessCommand ###############################################################

describe ProcessCommand do

  before :each do
    @cmd = ProcessCommand.new
  end

  include_examples 'all_commands', ProcessCommand, 'process'

end # describe ProcessCommand
