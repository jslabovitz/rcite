# Top-level module for the RCite application/library.
module RCite
  # Ancestor class for all user-defined styles. This class defines a unified
  # interface for styles (namely the {#cite} and {#bib} method) as well
  # as providing various helper methods to ease creating new styles.
  #
  # The 'workflow' of the Style class goes as follows:
  #
  # 1. {#cite} or {#bib} are called with a BibTeX::Entry for the text that
  #    is to be cited. They check if their style object has a
  #    `cite_type` and `bib_type` method respectively, where `type` is the
  #    BibTeX entry type for the current text. If so, they set {#text}
  #    accordingly and reset {#elements}.
  # 2. The `cite_type` and `bib_type` methods use {#add} to add
  #    {RCite::Element}s to {#elements}.
  # 3. When these methods return, the actual citation/bibliography entry
  #    is constructed from {#elements}.
  class Style

    # A BibTeX::Entry that describes the text currently being processed. Should
    # not be changed by any methods except {#cite} and {#bib}. See {Style} for
    # information on the RCite 'workflow'.
    #
    # @return [BibTeX::Entry] The current text's entry.
    attr_accessor :text

    # Array of {RCite::Element}s for the current {#text}. See {Style} for
    # information on the RCite 'workflow'.
    #
    # @return [Array<RCite::Element>] 
    attr_accessor :elements

    # @overload around(quantifier, command)
    #
    #   Returns the text that should be printed before and after the given
    #   quantifier-command combination. These can be the following:
    #
    #   1. **around :all, :bibs** -- text to put around a whole `bib` command in
    #      preprocessing mode. The command may generate bibliography entries for
    #      multiple texts, and their 'concatenation' is enclosed in this text.
    #   2. **around :each, :bib** -- text to be put around each individual
    #      bibliography entry in a `bib` command in preprocessing mode.
    #   3. **around :all, :cites** -- text to be put around all citations of
    #      a preprocessing `cite` command.
    #   4. **around :each, :cite** -- text to be put around each citation of a
    #      preprocessing `cite` command.
    #
    #   You may also use the {#before} and {#after} methods to specify those
    #   strings.
    #
    #   @example
    #     around :all, :cites, '<begin>', '<end>'
    #       # results in the following citation:
    #       # <begin>citation1; citation2<end>
    #     around :each, :cite, '<begin>', '<end>'
    #       # results in the following citation:
    #       # <begin>citation1<end>; <begin>citation2<end>
    #
    #   @param [Symbol] quantifier either `:all` or `:each`.
    #   @param [Symbol] command one of `:cite`, `:cites`, `:bib`, `:bibs`.
    #     `:cite` are equivalent (i.e. the same result is returned for both),
    #     as are `:bib` and `:bibs`.
    #
    #   @return [Array<String>] An array of strings, where the first value
    #     is text to be printed before the given quantifier-command combination,
    #     and the second value is text to be printed after it.
    #
    # @overload around(quantifier, command, before_string, after_string)
    #   
    #   Indicates that the given strings should be put before and after the
    #   given quantifier-command combination. For details and examples see
    #   above.
    #
    #   @param [Symbol] quantifier either `:all` or `:each`.
    #   @param [Symbol] command one of `:cite`, `:cites`, `:bib`, `:bibs`.
    #     `:cite` are equivalent (i.e. the same result is returned for both),
    #     as are `:bib` and `:bibs`.
    #   @param [String] before_string String to be printed before the given
    #     quantifier-command combination. If this is `nil`, it will be
    #     ignored, i.e. the old `before_string` remains in place. To
    #     override it, use an empty string.
    #   @param [String] after_string String to be printed after the given
    #     quantifier-command combination. If this is `nil`, it will be
    #     ignored, i.e. the old `after_string` remains in place. To
    #     override it, use an empty string.
    #
    #   @return [Array] `[before_string, after_string]`
    def around(*args)
      @around  ||= {}

      # Overload 1
      if args.size == 2
        quant, cmd = args[0..1]

        cmd = :cite if cmd == :cites
        cmd = :bib  if cmd == :bibs

        return @around[[quant, cmd]] || []
      end

      # Overload 2
      quant, cmd, before, after = args[0..3]

      cmd = :cite if cmd == :cites
      cmd = :bib  if cmd == :bibs
      before = around(quant, cmd)[0] unless before
      after  = around(quant, cmd)[1] unless after

      @around[[quant, cmd]] = [before, after] 
    end

    # Alias for {#around}`(quantifier, command, before_string, nil)`.
    def before(quantifier, command, before_string)
      around(quantifier, command, before_string, nil)
    end

    # Alias for {#around}`(quantifier, command, nil, after_string)`.
    def after(quantifier, command, after_string)
      around(quantifier, command, nil, after_string)
    end

    # @overload between(key)
    #
    #   Returns the separator to be put between multiple citations/bibliography
    #   entries in preprocessing mode. For an example, see below.
    #
    #   @param [Symbol] key one of:
    #
    #     1. :cites -- the value of this key is a `String` that should be put
    #        between each citation of a preprocessing `cite` command.
    #     2. :bibs -- the value of this key is a `String` that should be put
    #        between each bibliography entry of a preprocessing `bib` command.
    #
    #   @return [String] Text to be put between multiple citations/bibliography
    #     entries.
    #
    # @overload between(key, between_string)
    #
    #   Associates the given `between_string` with either citations or
    #   bibliography entries, depending on whether `key` is `:bibs` or `:cites`.
    #
    #   @example
    #     between :cites, '|||'
    #       # results in the following citations:
    #       # citation1|||citation2
    #     between :bibs, '; '
    #       # results in the following bibliography entries:
    #       # bibentry1; bibentry2
    #
    #   @param [Symbol] key either :bibs or :cites, depending on whether
    #     `between_string` should be put between citations or bibliography
    #     entries in preprocessing mode.
    #   @param [String] between_string The string to put between citations or
    #     bibliograpy entries.
    #
    #   @return [String] `between_string`
    def between(*args)
      @between ||= {cites: '; ', bibs: "\n"}

      if args.size == 1
        @between[args[0]]
      else
        @between[args[0]] = args[1]
      end
    end

    # Generates a citation for the given `text`. This method
    #
    # 1. Merges `text.to_hash` and `fields` whereby values from `fields` take
    #    precedence.
    # 2. Sets `@text` to the merge result. When this method returns, `@text` is
    #    set to `nil` again.
    # 3. Looks up the method `"cite_#{text.type}"` and calls it.
    #
    # @param [BibTeX::Entry] text A bibliography entry in `bibtex-ruby`'s
    #   format.
    # @param [Hash] fields A hash where each key is a BibTeX field and each
    #   value is that field's value. This can be used to set fields 'on the
    #   fly', most notably the `thepage` field that indicates which page the 
    #   user wants to cite.
    #
    # @raise ArgumentError if the style does not support the given entry's
    #   `type`.
    #
    # @return [String] The citation.
    def cite(text, fields = {})
      method = "cite_#{text.type}"
      if !respond_to?(method, true)
        raise ArgumentError.new("This style does not define the type"+
          "' #{text.type}'.")
      end
      @text = text.dup << fields
      @elements = []
      begin
        send(method)
      ensure
        @text = nil
      end
      elements_to_string(@elements)
    end
    
    # Generates a bibliography entry for the given `text`. This method
    #
    # 1. Merges `text.to_hash` and `fields` whereby values from `fields` take
    #    precedence.
    # 2. Sets `@text` to the merge result. When this method returns, `@text` is
    #    set to `nil` again.
    # 3. Looks up the method `"bib_#{text.type}"` and calls it.
    #
    # @param (see #cite)
    #
    # @raise (see #cite)
    #
    # @return [String] The bibliography entry.
    def bib(text, fields = {})
      method = "bib_#{text.type}".to_s
      if !respond_to?(method, true)
        raise ArgumentError.new("This style does not define the type"+
          " '#{text.type}'.")
      end
      @text = text.dup << fields
      @elements= []
      begin
        send(method) 
      ensure
        @text = nil
      end
      elements_to_string(@elements)
    end

    #################################BEGIN PRIVATE##############################

    private

    # Concatenates Element contents to one string. If the element is of type
    # `:con`, its content is immediately appended to the string. If it is of type
    # `:sep`, the following rules apply:
    #
    # 1. All separators are removed from the tail of the index until a
    #    content Element is encountered.
    # 2. If the element is the first item in the list, it is dropped.
    # 3. If the element is the last item in the list, it is dropped.
    # 4. If the preceding element is a separator as well, the current element is
    #    dropped.
    # 5. Otherwise it is appended to the string.
    #
    # @param [Array<Element>] elements An array of Element objects.
    #
    # @return [String] A string constructed by omitting useless separator elements
    #   and concatenating the rest together.
    def elements_to_string(elements)
      string = ''
      # Deletes the longest possible range of separators from the end of
      # the array.
      elements = elements.reverse.drop_while {|e| e.type == :sep}
      elements.reverse!.compact!

      # Checks if the rest of the above rules are fulfilled.
      elements.each_index do |i|
        e = elements[i]
        if e.type == :sep
          if i != 0 && elements[i-1].type != :sep && \
             elements[i-1].content != nil && elements[i-1].content != ''
            string << e.content if e.content
          end
        else
          string << e.content if e.content
        end
      end
      string
    end #elements_to_string

  end # class Style
end # module RCite
