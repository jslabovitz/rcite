# Top-level module for the RCite application/library.
module RCite
  # Ancestor class for all user-defined styles. This class defines a unified
  # interface for styles (namely the {#cite} and {#bib} method) as well
  # as providing various helper methods to ease creating new styles.
  class Style

    # Generates a citation for the given `text`. This method dynamically
    # looks up the method `"cite_#{text.type}"` and calls it with
    # `text` as the only argument. Before that it sets the `$text` global 
    # variable to be `text` so that the method it calls can access it.
    # When this method returns, `$text` is set to `nil` again.
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
      $text = text
      $tmp = []
      begin
        send(method)
      ensure
        $text = nil
      end
      elements_to_string($tmp)
    end
    
    # Generates a bibliography entry for the given `text`. This method dynamically
    # looks up the method `"bib_#{text.type}"` and calls it with
    # `text` as the only argument. Before that it sets the `$text` global 
    # variable to be `text` so that the method it calls can access it.
    # When this method returns, `$text` is set to `nil` again.
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
      $text = text
      $tmp = []
      begin
        send(method) 
      ensure
        $text = nil
      end
      elements_to_string($tmp)
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
