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

    # Generates a citation for the given `text`. This method dynamically
    # looks up the method `"cite_#{text.type}"` and calls it with
    # `text` as the only argument. Before that it sets the `@text` 
    # variable to be `text` so that the method it calls can access it.
    # When this method returns, `@text` is set to `nil` again.
    #
    # @param [BibTeX::Bibliography] text A bibliography in `bibtex-ruby`'s
    #   format.
    # @raise ArgumentError if the style does not support the given entry's
    #   `type`.
    # @return [String] The citation.
    def cite(text)
      method = "cite_#{text.type}"
      if !respond_to?(method)
        raise ArgumentError.new("This style does not define the type"+
          "' #{text.type}'.")
      end
      @text = text
      @elements = []
      begin
        send(method)
      ensure
        @text = nil
      end
      elements_to_string(@elements)
    end
    
    # Generates a bibliography entry for the given `text`. This method dynamically
    # looks up the method `"bib_#{text.type}"` and calls it with
    # `text` as the only argument. Before that it sets the `@text` global 
    # variable to be `text` so that the method it calls can access it.
    # When this method returns, `@text` is set to `nil` again.
    #
    # @param (see #cite)
    # @raise (see #cite)
    # @return [String] The bibliography entry.
    def bib(text)
      method = "bib_#{text.type}".to_s
      if !respond_to?(method)
        raise ArgumentError.new("This style does not define the type"+
          " '#{text.type}'.")
      end
      @text = text
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
    # 1. All seperators are removed from the tail of the index until a
    #    content Element is encountered.
    # 2. If the element is the first item in the list, it is dropped.
    # 3. If the element is the last item in the list, it is dropped.
    # 4. If the preceding element is a seperator as well, the current element is
    #    dropped.
    # 5. Otherwise it is appended to the string.
    #
    # @param [Array<Element>] elements An array of Element objects.
    # @return [String] A string constructed by omitting useless seperator elements
    #   and concatenating the rest together.
    def elements_to_string(elements)
      string = ''
      # Deletes the longest possible range of seperators from the end of
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
    end
  end
end
