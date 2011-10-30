# Top-level module for the RCite application/library.
module RCite
  # Ancestor class for all user-defined styles. This class defines a unified
  # interface for styles (namely the {#cite} and {#bib} method) as well
  # as providing various helper methods to ease creating new styles.
  class Style

    # Constructs a new `Style` object.
    def initialize
    end

    # Generates a citation for the given `text`. This method dynamically
    # looks up the method `cite_#!{text[:type]}` and calls it with
    # `text` as the only argument.
    #
    # @param [Hash] text A bibliography entry hash
    #   in the 'citeproc' format as returned by `BibTeX::Entry#to_citeproc`
    # @raise ArgumentError if the style does not support the given entry's
    #   `type`.
    def cite(text)
      method = "cite_#{text[:type]}".to_s
      if !respond_to?(method)
        raise ArgumentError.new("This style does not define the type"+
          "'#{text[:type]}'.")
      end
      send(method, text)
    end
    
    # Generates a bibliography entry for the given `text`. This method dynamically
    # looks up the method `bib_#!{text[:type]}` and calls it with
    # `text` as the only argument.
    #
    # @param (see #cite)
    # @raise (see #cite)
    def bib(text)
      method = "bib_#{text[:type]}".to_s
      if !respond_to?(method)
        raise ArgumentError.new("This style does not define the type"+
          "'#{text[:type]}'.")
      end
      send(method, text) 
    end
  end
end
