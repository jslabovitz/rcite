# Top-level module for the RCite application/library.
module RCite
  # Ancestor class for all user-defined styles. This class defines a unified
  # interface for styles (namely the {#cite} and {#bib} method) as well
  # as providing various helper methods to ease creating new styles.
  class Style

    # Generates a citation for the given `text`. This method dynamically
    # looks up the method `"cite_#{text[:type]}"` and calls it with
    # `text` as the only argument. Before that it sets the `$text` global 
    # variable to be `text` so that the method it calls can access it.
    # When this method returns, `$text` is set to `nil` again.
    #
    # @param [Hash] text A bibliography entry hash
    #   in the 'citeproc' format as returned by `BibTeX::Entry#to_citeproc`
    # @raise ArgumentError if the style does not support the given entry's
    #   `type`.
    # @return [String] The citation.
    def cite(text)
      method = "cite_#{text[:type]}".to_s
      if !respond_to?(method)
        raise ArgumentError.new("This style does not define the type"+
          "'#{text[:type]}'.")
      end
      $text = text
      begin
        send(method, text)
      ensure
        $text = nil
      end
    end
    
    # Generates a bibliography entry for the given `text`. This method dynamically
    # looks up the method `"bib_#{text[:type]}"` and calls it with
    # `text` as the only argument. Before that it sets the `$text`global 
    # variable to be `text` so that the method it calls can access it.
    # When this method returns, `$text` is set to `nil` again.
    #
    # @param (see #cite)
    # @raise (see #cite)
    # @return [String] The bibliography entry.
    def bib(text)
      method = "bib_#{text[:type]}".to_s
      if !respond_to?(method)
        raise ArgumentError.new("This style does not define the type"+
          "'#{text[:type]}'.")
      end
      $text = text
      begin
        send(method, text) 
      ensure
        $text = nil
      end
    end
  end
end
