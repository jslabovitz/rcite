module RCite
  # Represents an option. `Option` objects provide useful helper methods for
  # the flexible validation and transformation of option values.
  class Option

    include Comparable

    # @return [Symbol] This option's name. Should be descriptive yet short
    #   because {Style} creates helper methods whose names are derived from
    #   this attribute.
    attr_accessor :name
    # This option's current value(s). If the option has multiple values, they
    #   are represented by an `Array` (which may include more `Array`s for value
    #   tupels and such).
    # @return [Object,nil] This option's current value(s). May be `nil` if the
    #   option has not yet been set.
    attr_accessor :values

    # An Object indicating which transformation should be applied to values
    # that are added using {#set}. Can be one of the following:
    #
    # 1. A `Proc` object -- for each value transformation, the Proc is called
    #    with the value as the only argument.
    # 2. One of the standard classes `String`, `Symbol`, `Integer` and `Float`
    #    -- this option will attempt to transform each value to an object of
    #    the given class. Transforms to `nil` if the value does not respond
    #    to the respective conversion method.
    # 3. `true` or `false` -- values are converted to `true` or `false`. If a
    #    value is `false`, `nil`, `"false"` or `:false`, it is converted to
    #    `false`; other values are converted to `true`.
    # 4. Any `Class` objects -- values are replaced with the return value of
    #    `class.new(value)`. Transforms to `nil` if the given class does not
    #    respond to `new`. May throw errors if the class's constructor demands
    #    other parameters.
    #
    # @example Proc object
    #   style.transformer = proc { |val| val.map(&:strip) }
    #   style.transform(' stuff ') # => 'stuff'
    # @example Standard classes
    #   style.transformer = String
    #   style.transform(:symbol)   # => 'symbol'
    # @example true/false
    #   style.transformer = true
    #   style.transform(:false)    # => false
    # @example other classes
    #   style.transformer = Option
    #   style.transform(:opt_name) # => Option (with name == :opt_name)
    #
    # @return [Object] This options's transformer.
    attr_accessor :transformer
    # @return [Object,nil] Default value for this option. Needs not be valid in
    #   the sense of {#validate}. May be an array of arbitrary objects
    #   (including other arrays).
    attr_accessor :default

    # @return [Proc,nil] A `Proc` that is used to determine (together with
    #   `#good_values`, `#bad_values` and `#allow_nil`) whether 
    attr_accessor :validator
    # @return [true,false] Determines whether `nil` values are allowed.
    attr_accessor :allow_nil
    # List of objects that are valid values for this option. This list is
    # non-exclusive, so items that are not on it may still be valid according
    # to the {#validator}.
    #
    # This list takes precedence over {#bad_values}, so if an item is listed
    # on both, it is considered valid.
    #
    # @example Making good_values exclusive
    #   # With the following options set, all values that are not on this
    #   # list will be discarded.
    #   style.good_values = [:good, :values]
    #   style.validator   = proc { false }
    #
    # @return [Array<Object>] List of objects that are valid values for
    #   this option.
    attr_accessor :good_values
    # List of objects that are invalid values for this option.
    #
    # {#good_values} takes precedence over this list, so if an item is present
    # on that list as well, it is considered valid.
    #
    # @return [Array<Object>] List of objects that are invalid values for
    #   this option.
    attr_accessor :bad_values

    # Creates a new Option. All instance variables can be set using the options
    # hash.
    #
    # @example
    #   Option.new(:opt_name, allow_nil:   false,
    #                         validator:   { |val| ! val.empty? }) do |val|
    #     val.is_a?(Array) ? val.map(&:strip) : val
    #   end
    #
    # @param [#to_sym] name This option's name. May neither be `nil` nor an
    #   empty string. Please make sure that no two options have the same name,
    #   as this would likely lead to confusion.
    #
    # @param [Hash] options Options hash. Keys correspond to public attributes
    #   of this class; values are their value.
    # @param &block The block, if one is given, is turned into a `Proc` object
    #   and assigned to the {#transformer} attribute.
    #
    # @raise ArgumentError if `name` is `nil` or empty.
    def initialize(name, options = {}, &block)
      raise ArgumentError, 'name cannot be empty' unless name && name != ''

      @name = name.to_sym
      @transformer = Proc.new if block_given?
      @allow_nil = true
      @good_values, @bad_values = [], []

      options.each_pair do |k,v|
        method = (k.to_s+'=').to_sym
        raise ArgumentError, 'invalid option: #{k}' unless respond_to?(method)
        send(method, v)
      end

      @values ||= @default
    end #initialize

    # Assigns one or more values to this option. Performs all validations
    # and transformations prior to assignment. Validation is performed after
    # transformation so you have the possibility of 'rescuing' invalid values
    # by transforming them.
    #
    # If multiple values are given, they are turned into a flattened array and
    # compacted before the assignment. The `#allow_nil` directive is only
    # considered violated if _all_ elements of `values` are `nil`. This is
    # determined prior to transformation and validation.
    #
    # If `values` contains exactly one element after validation and
    # transformation, `#values` is assinged a single object rather than an
    # `Array`.
    #
    # @param [Array<Object>] values One or more values that should be assigned
    #   to this option.
    # @return [Array<Object>,Object,nil] The final value assigned to {#values}.
    def set(*values)
      vals = values.flatten.compact

      if vals.empty?
        unless @default || @allow_nil
          raise ArgumentError, "Nil values are not allowed for option #{@name}."
        end
        return @values = @default
      end

      vals.each do |val|
        transform!(val)
        unless validate(val)
          raise ArgumentError, "Invalid value for option #{@name}: '#{val}'."
        end
      end

      @values = vals.size == 1 ? vals[0] : vals
    end #set

    alias :values= :set
    alias :get :values

    # Validates a value for this option. Tests the following conditions (in
    # the specified order):
    #
    # 1. {#good_values} includes the value; if so `true` is returned and all
    #    other validations are skipped.
    # 2. {#bad_values} includes the value; if so `false` is returned and all
    #    other validations are skipped.
    # 3. {#validator} is `nil`; if so `true` is returned.
    # 4. If the above validations don't succeed or fail, the return value of
    #    {#validator}`.call(value)` is returned.
    #
    # @param [Object] value The value whose validity should be determined.
    # @return [true,false] `true` if `value` is valid, `false` otherwise.
    def validate(value)
      return true  if @good_values.include?(value)
      return false if @bad_values. include?(value)
      return true  unless @validator
      return @validator.call(value)
    end #validate

    # Transforms `value` in-place according to the procedure specified by
    # {#transformer}. See the discussion there for further information.
    #
    # @param [Object] value the value that should be transformed.
    # @return [Object] the transformed value.
    def transform!(value)
      if @transformer.is_a?(Class)
        return case @transformer.to_s
        when 'String'  then value.respond_to?(:to_s)   ? value.to_s   : nil
        when 'Symbol'  then value.respond_to?(:to_sym) ? value.to_sym : nil
        when 'Integer' then value.respond_to?(:to_i)   ? value.to_i   : nil
        when 'Float'   then value.respond_to?(:to_f)   ? value.to_f   : nil
        else @transformer.respond_to?(:new) ? @transformer.new(value) : nil
        end
      end

      case @transformer
      when true, false
        case value
        when true, false          then value
        when nil, "false", :false then false
        else true
        end
      when Proc
        @transformer.call(value)
      else
        value
      end
    end #transform!

    # Sets the {#name} attribute.
    #
    # @param name (see #initialize)
    # @return `name`
    # @raise (see #initialize)
    def name=(name)
      raise ArgumentError, 'name cannot be empty' unless name && name != ''
      @name = name.to_sym
    end #name=

    # Sets the {#good_values} attribute. The given parameter array `values` is
    # flattened before assignment. If `values` consists of exactly one empty
    # `Array`, the attribute value remains unchanged.
    #
    # @param [Array<Object>] values Values to be added to the list of 'good'
    #   values.
    # @return [void]
    def good_values=(*values)
      @good_values = []
      return if values.size == 1 && values[0] == []
      values.flatten.each { |v| @good_values << v }
    end #good_values=

    # Sets the {#bad_values} attribute. The given parameter array `values` is
    # flattened before assignment. If `values` consists of exactly one empty
    # `Array`, the attribute value remains unchanged.
    #
    # @param [Array<Object>] values Values to be added to the list of 'bad'
    #   values.
    # @return [void]
    def bad_values=(*values)
      @bad_values = []
      return if values.size == 1 && values[0] == []
      values.flatten.each { |v| @bad_values << v }
    end #bad_values=

    # Compares this option with `other`. The option's {#name} is the sole
    # criterion for comparison. Therefore you are advised to make sure that no
    # two options share the same `name`.
    #
    # @param [Option] other Another option.
    # @return [-1,0,1] `self.name <=> other.name`
    def <=>(other)
      @name <=> other.name
    end #<=>

  end
end
