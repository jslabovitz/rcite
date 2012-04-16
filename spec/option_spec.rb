require 'spec_helper'
include RCite

describe Option do

  before :each do
    @o = Option.new('opt_name')
  end

  describe '#initialize' do

    it 'should initialize @values with the default' do
      @o = Option.new('opt_name', default: :def)
      @o.get.should == :def
    end

    context 'when called with a block' do
      it 'should set @transformer to a proc that executes the block' do
        @o = Option.new('opt_name') { |val| val }
        @o.transformer.call("value").should == "value"
      end
    end

    context 'when called with an options hash' do
      it 'should set the appropriate instance variables' do
        @o = Option.new('opt_name', allow_nil: true, good_values: :val1)

        @o.allow_nil.  should == true
        @o.good_values.should == [:val1]
      end
    end

    context 'when called with an invalid options hash' do
      it 'should raise an ArgumentError' do
        expect { Option.new('opt_name', no_such_attribute: :val) }.to
          raise_error ArgumentError
      end
    end

    context 'when called with a name of `nil` or an empty string' do
      it 'should raise an ArgumentError' do
        expect { Option.new(nil) }.to raise_error ArgumentError
        expect { Option.new('')  }.to raise_error ArgumentError
      end
    end

  end # describe #initialize

  describe '#set' do

    context 'when called with more than one value argument' do
      it 'should turn all the value arguments into a flattened Array' do
        @o.set(:arg1, :arg2, [:arg3, :arg4])
        @o.get.should == [:arg1, :arg2, :arg3, :arg4]
      end
    end

    context 'when called with exactly one argument' do
      it 'should set @values accordingly' do
        @o.set(:arg1)
        @o.get.should == :arg1
      end
    end

    it 'should validate and transform all the value arguments' do
      @o.should_receive(:validate).with(:arg1).and_return(true)
      @o.should_receive(:validate).with(:arg2).and_return(true)
      @o.should_receive(:transform!).with(:arg1)
      @o.should_receive(:transform!).with(:arg2)
      @o.set(:arg1, :arg2)
    end

    context 'if there are any invalid arguments' do
      it 'should raise an ArgumentError' do
        @o.stub(:validate).and_return(false)
        expect { @o.set(:val) }.to raise_error ArgumentError
      end
    end

    context 'if the value is `nil`' do
      it 'should skip validation and transformation' do
        @o.transformer = proc {}
        @o.validator   = proc {}
        @o.transformer.should_not_receive(:call)
        @o.validator.  should_not_receive(:call)
        @o.set(nil)
      end
    end

    context 'if the value is `nil` but nil arguments are not allowed' do
      it 'should raise an ArgumentError' do
        @o.allow_nil = false
        expect { @o.set(nil) }.to raise_error ArgumentError
      end
    end

    context 'if the value is `nil` and there is a default value' do
      it 'should assign the default value' do
        @o.default = :default
        @o.set(nil)
        @o.get.should == :default
      end
    end

  end # describe #set

  describe '#validate' do

    it 'should call @validator for the given value' do
      validator = proc { :validated  }
      validator.should_receive(:call).with(:value1)
      @o.validator = validator

      @o.validate(:value1)
    end

    context 'if @validator == nil' do
      it 'should return true' do
        @o.validator = nil
        @o.validate(:stuff).should == true
      end
    end

    context 'if both @good_values and @bad_values include the value' do
      it '@good_values should precede' do
        @o.good_values << :val2
        @o.bad_values  << :val2
        @o.validate(:val2).should == true
      end
    end

    context 'if @good_values is set and the value is not included' do
      it 'should continue validating' do
        @o.good_values = :val2
        @o.validator = proc { true }
        @o.validator.should_receive(:call).with(:val)
        @o.validate(:val)
      end
    end

    context 'if @good_values is set and the value is included' do
      it 'should skip validation and return true' do
        @o.good_values = :arg1
        @o.validator = proc { false }
        @o.validator.should_not_receive(:call)
        @o.validate(:arg1).should == true
      end
    end

    context 'if @bad_values is set and the value is included' do
      it 'should skip validation and return false' do
        @o.bad_values = :arg1
        @o.validator  = proc { true }
        @o.validator.should_not_receive(:call)
        @o.validate(:arg1).should == false
      end
    end

    context 'if @bad_values is set and the value is not included' do
      it 'should continue validating' do
        @o.bad_values = :arg2
        @o.validator  = proc { false }
        @o.validator.should_receive(:call).with(:arg1)
        @o.validate(:arg1)
      end
    end

    context 'if the given value is invalid' do
      it 'should return false' do
        @o.validator = proc { false }
        @o.validate(:arg1).should == false
      end
    end

    context 'if the given value is valid' do
      it 'should return true' do
        validator = proc { true }
        @o.validator = validator
        @o.validate(:arg1).should == true
      end
    end

  end # describe #validate

  describe '#transform!' do

    context 'if @transformer is one of the standard classes' do
      it 'should convert the value to an object of that class' do
        @o.transformer = String
        @o.transform!(:to_string).should == 'to_string'
        @o.transformer = Integer 
        @o.transform!('256'     ).should == 256
        @o.transformer = Float
        @o.transform!('2.56'    ).should == 2.56
        @o.transformer = Symbol
        @o.transform!('to_sym'  ).should == :to_sym
      end

      context 'and the value won\'t let us convert it to an @transformer object' do
        it 'should return nil' do
          @o.transformer = Symbol
          @o.transform!(256).should == nil
        end
      end
    end

    context 'if @transformer is a class but not one of the standard ones' do
      it 'should convert the value using the class\'s constructor' do
        @o.transformer = Style
        @o.transformer.should_receive(:new).with(:value)
        @o.transform!(:value)
      end
    end

    context 'if @transformer is a Proc' do
      it 'should convert the value using the Proc' do
        @o.transformer = proc { |val| val*2 }
        @o.transform!(2).should == 4
      end
    end

    context 'if @transformer is `true` or `false`' do
      it 'should convert the value into a boolean value' do
        @o.transformer = true
        @o.transform!('false').   should == false
        @o.transform!(:false).    should == false
        @o.transform!(Object.new).should == true
        @o.transform!(false).     should == false
      end
    end

    context 'if @transformer is `nil`' do
      it 'should return the argument unchanged' do
        @o.transformer = nil
        val = 'value'
        @o.transform!(val).should be(val)
      end
    end

  end # describe #transform

  describe '#good_values=,#bad_values=' do

    context 'when called with an argument that is not an array' do
      it 'should turn it into a one element array' do
        @o.good_values = :arg1
        @o.bad_values  = :arg1
        @o.good_values.should == [:arg1]
        @o.bad_values. should == [:arg1]
      end
    end

  end # describe #good_values=,#bad_values=

  describe '#name=' do

    it 'should transform its argument to a symbol' do
      @o.name = 'symbol'
      @o.name.should == :symbol
    end

    context 'when called with `nil` or an empty string' do
      it 'should raise an ArgumentError' do
        expect { @o.name = ''  }.to raise_error ArgumentError
        expect { @o.name = nil }.to raise_error ArgumentError
      end
    end

  end # describe #name

  describe '#<=>' do
    it 'should compare two options according to their name' do
      o2 = Option.new(:stuff)
      (o2 <=> @o).should == (o2.name <=> @o.name)
    end
  end

end # describe Option
