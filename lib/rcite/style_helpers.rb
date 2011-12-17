require 'rcite/element'

module RCite
  class Style

    # The default options hash. Whenever a method with an
    # `options` parameter is executed, it will merge the `options`
    # hash submitted by the user with this one. This allows style authors
    # to set a global default behaviour for various helper methods, but also
    # allows them to override it in special cases.
    #
    # For details on which options are relevant for which method, see
    # the respective method documentation.
    #
    # @return [Hash] The hash with default options.
    attr_accessor :defaults

    # The default values for the {#defaults} hash. These are loaded if the
    # style does not define some itself using the `default` method.
    # See {#initialize}.
    DEFAULTS = {
      :ordering     => :last_first,
      :delim        => '; ',
      :et_al        => 3,
      :et_al_string => 'et al.',
    }

    # These fields can be accessed through helper methods that are each
    # named just as their respective field. Other fields that may also
    # be defined in the BibTeX document can only be accessed directly via
    # the hash, e.g. `$text[:unusual_field]`.
    #
    # In addition to the fields defined here, this class provides helper methods
    # for the more complex {#author} and {#editor}.
    # details.

    FIELDS = %w{
      address
      annote
      booktitle
      chapter
      crossref
      edition
      howpublished
      institution
      journal
      key
      month
      note
      number
      organization
      pages
      publisher
      school
      series
      title
      type
      volume
      year
    }


    FIELDS.each do |f|
      define_method(f) do
        $text[f.to_sym]
      end
    end

    # Loads the default options. Style authors may define the method `default`
    # which should return an options hash (see {#defaults}). If they do so,
    # the options from their hash are merged with {DEFAULTS}, whereby the
    # options returned by the `default` method supersede those from
    # `DEFAULTS`.
    def initialize
      @defaults = methods.include?(:default) ? default : {}
      @defaults.merge!(DEFAULTS) {|key, v1, v2| v1}
      $tmp = []
    end

    # Adds the specified `elements` to the global variable `$tmp`. Each
    # element can be either a `String` or an `Element`. `String`s are
    # converted to `Elements` of type `:con` before appending. `nil` arguments
    # and empty strings are dropped.
    #
    # @param [Element,String] elements Any number of elements or strings
    #   that should be appended to $tmp.
    def add(*elements)
      elements.map! do |e|
        if e.is_a? RCite::Element
          e
        elsif e && e.to_s == ''
          nil
        elsif e
          RCite::Element.new(:con, e)
        end
      end

      $tmp.concat elements.compact
    end

    # Defines a seperator element. This method is a very simple helper method
    # for style generation which can be used to indicate that `seperator` is
    # a seperator, not bibliographic data. This method should be used in
    # conjunction with {#add}, as shown in the example.
    #
    # @example Using `sep` with `add`
    #   add authors
    #   add sep ': '
    #   add title
    #
    # @param [String] seperator Some string that should be used as a seperator.
    #
    # @return [Element] An `Element` of type `:sep` with `seperator` as the
    #   element's `content`.
    def sep(seperator)
      RCite::Element.new(:sep, seperator)
    end

    # Returns a list of all authors of the given text if any are defined.
    #
    # @param [Hash] options Controls the style of the list generated by this
    #   method.
    #   
    # @option options [:first_last, :last_first] :ordering Controls
    #   the order in which family and given names are printed. If `:first_last`
    #   is given, Mr Theodor zu Guttenberg is printed as
    #   "Theodor zu Guttenberg". For `:last_first` it's
    #   "zu Guttenberg, Theodor".
    # @option options [String] :delim The list delimiter.
    # @option options [Integer] :et_al The maximum number of persons that are
    #   listed. If there are more person, `:et_al_string` is added to the end
    #   of the list.
    # @option options [String] :et_al_string The term that is appended when
    #   more than `:et_al` persons are given.
    # 
    # @return [String, nil] The list of authors, or `nil` if the bibliographic
    #   data for this text defines none.
    def authors(options = {})
      authors_or_editors($text[:author].to_names, options) if $text[:author]
    end

    alias author authors

    # Returns a list of all editors of the given text if any are defined.
    #
    # @param (see #authors)
    # @option (see #authors)
    # @return [String,nil] The list of editors, or `nil` if the bibliographic
    #   data for this text defines none.
    def editors(options = {})
      authors_or_editors($text[:editor].to_names, options) if $text[:editor]
    end

    alias editor editors

    #=========================== BEGIN PRIVATE ================================

    private

    def authors_or_editors(list, options = {})
      return if list == nil
      merge_defaults(options)

      list = list.map do |person|
        string = ''
        case options[:ordering]
          when :last_first
            string << list([person.prefix, person.last], " ")
            string << ", #{person.first}" if person.first
          when :first_last
            string << list([person.first, person.prefix, \
                            person.last], " ")
        end
        string
      end

      print_et_al = false
      max_num_of_persons = options[:et_al]
      if max_num_of_persons && list.size > max_num_of_persons
        list = list[0..(max_num_of_persons-1)]
        print_et_al = true
      end

      string = list(list, options[:delim])

      string << " " + options[:et_al_string] if print_et_al
      return string
    end

    def merge_defaults(options)
      options.merge!(@defaults) { |key, v1, v2| v1 } if options && defaults
    end

    def list(list, delim)
      list.compact.join(delim)
    end

  end
end
