require 'style'

module RCite

  # The `Processor` class is responsible for chaining the two steps involved
  # in creating a citation or bibliography together:
  #
  # 1. Load a (BibTeX) file with bibliographic information about all the texts.
  # 2. Load a style that defines how to construct citations and bibliography
  #    entries from the former.
  # 
  # Moreover, it provides shortcuts for citing and bibliography entry creation
  # by mapping {RCite::Style#cite} and {RCite::Style#bib}.
  class Processor

    # The style that is used to turn bibliographic data gathered from a
    # (BibTeX) file to actual citations/bibliographic entries. Should
    # usually be a subclass of {RCite::Style}. Can be `nil` if no style
    # has been loaded yet.
    attr_accessor :style

    # A hash with bibliographic data loaded from a (BibTeX) file, as returned
    # by the bibtex-ruby gem's `BibTeX::Bibliography#to_citeproc`. Can be `nil` if
    # no data file has been loaded yet.
    attr_accessor :bibliography
    
    # Loads a style file. The file must define a class with the same name as
    # its basename camelized, in the {RCite} module.
    #
    # So for example, `some_style.rb` must define `RCite::SomeStyle` and
    # `another_style.rb` must define `RCite::AnotherStyle`.
    #
    # If the file is loaded successfully, an instance of the class defined
    # in it is assigned to {#style}.
    #
    # @param [String] file Relative or absolute path of the file that should
    #   be loaded.
    # @raise [ArgumentError] if the file does not define a class that matches
    #   the filename, or if the class that is defined there does not
    #   provide the {RCite::Style#bib} and {RCite::Style#cite} methods.
    def load_style(file)
      # Load the file content
      require "#{file}" 

      # Guess the style's classname from the filename. The following
      # chain of operations determines the given file's basename, strips
      # the .rb ending and camelizes the rest. The result should be the
      # name of the class that is defined in the file.
      classname = file.to_s.sub(/.rb$/, "").match(/\/[a-zA-Z_0-9]+$/)[0].
        gsub(/\/(.?)/) { $1.upcase }.gsub(/(?:^|_)(.)/) { $1.upcase }
      begin
        @style = RCite.const_get(classname).new
      rescue
        raise ArgumentError.new "Expected classname #{classname} in file #{file}."
      end

      # Check if the class has `cite` and `bib` methods. If not, we can't
      # use it as a style.
      if !@style.respond_to?(:cite) || !@style.respond_to?(:bib)
        raise ArgumentError.new "Every style must define the 'cite' and 'bib'" +
          " instance methods."
      end
    end

    # Loads the specified BibTeX file and sets {#bibliography} accordingly. This method
    # is merely a wrapper for `BibTeX::Bibliography#open`.
    def load_data(file)
      @bibliography = BibTeX::Bibliography.open(file)
    end

    # Generates a citation for the `text` with given `id`. This method searches the
    # array of bibliographic data for a `text` with given `id` and -- if it happens
    # to find one -- returns `@style.cite(text)`.
    #
    # @param [Symbol] id The unique identifier set in the BibTeX file.
    # 
    # @raise [ArgumentError] if {#style} or {#bibliography} are `nil`, or if there is no
    #   text with given `id` in `bib`.
    #
    # @return [String] A citation for the given text.
    def cite(id)
      check_attrs

      text = find_text(id)
      if text
        @style.cite(text)    
      else
        raise ArgumentError.new "No text with id #{id} found."
      end
    end

    # Generates a bibliography entry for the `text` with given `id`. This method searches the
    # array of bibliographic data for a `text` with given `id` and -- if it happens
    # to find one -- returns `@style.bib(text)`.
    #
    # @param (see #cite)
    #
    # @raise (see #cite)
    #
    # @return [String] A bibliography entry for the given text.
    def bib(id)
      check_attrs

      text = find_text(id)
      if text
        @style.bib(text)    
      else
        raise ArgumentError.new "No text with id #{id} found."
      end
    end

    private

    # Searches for a text with given id.
    #
    # @param (see #cite)
    #
    # @return [Hash,nil] a Hash describing the text as returned by
    #   {BibTeX::Entry#to_citeproc}, or nil if a text with given id
    #   was not found.
    def find_text(id)
      text = @bibliography.select {|o| o[:id] == id.to_s}
      text ? text[0] : nil
    end

    # Checks if {#bibliography} and {#style} are defined (read: not `nil`).
    #
    # @raise [ArgumentError] if either is `nil`.
    def check_attrs
      raise ArgumentError.new "Please load a style first." unless @style
      raise ArgumentError.new "Please load bibliographic data first." unless @bibliography
    end
  end
end
