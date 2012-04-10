require 'rcite/style'
require 'bibtex'

module RCite

  # The `Processor` class is responsible for chaining the two steps involved
  # in creating a citation or bibliography together:
  #
  # 1. Load a BibTeX file with bibliographic information about all the texts.
  # 2. Load a style that defines how to construct citations and bibliography
  #    entries from the former.
  # 
  # Moreover, it provides shortcuts for citing and bibliography entry creation
  # by mapping {RCite::Style#cite} and {RCite::Style#bib}.
  class Processor

    # The style that is used to turn bibliographic data gathered from a
    # BibTeX file to actual citations/bibliographic entries. Should
    # usually be a subclass of {RCite::Style}. Can be `nil` if no style
    # has been loaded yet.
    attr_accessor :style

    # A `BibTeX::Bibliography` with bibliographic data loaded from a BibTeX
    # file. Can be `nil` if no data file has been loaded yet.
    attr_accessor :bibliography
    
    # Loads an RCite style.
    #
    # Styles simply consist of Ruby code (mainly method definitions) that
    # are executed in the context of a newly created class `RCite::TheStyle`
    # that inherits from {Style}. Think of the code in the style file as being
    # surrounded by
    #
    # ```ruby
    # class RCite::TheStyle < Style
    #
    # private
    #
    # # code from the style file
    # end
    # ```
    #
    # Note that all code added by the style file will be private by default.
    # This shouldn't make a difference because RCite will only communicate
    # with objects of the style via the public interface of {RCite::Style}.
    # If you still want to change it, use the `public` and `protected` methods
    # inside the style file.
    #
    # This method also sets {#style} to a new instance of the loaded class.
    #
    # @param [String] file Relative or absolute path of the file that should
    #   be loaded.
    #
    # @return [void]
    #
    # @raise [LoadError] if the specified file cannot be loaded by the Kernel
    #   method `load`.
    #
    # @api user
    def load_style(file)

      style = Class.new(RCite::Style) do
        load "#{File.absolute_path(file)}" 
      end

      RCite.send(:remove_const, :TheStyle) if RCite.const_defined?(:TheStyle)
      RCite.const_set(:TheStyle, style)

      @style = RCite::TheStyle.new
    end

    # Loads the specified BibTeX file and sets {#bibliography} accordingly.
    # This method is merely a wrapper for `BibTeX::Bibliography#open`.
    #
    # @param [String] file The BibTeX file that should be loaded.
    # @return [BibTeX::Bibliography] The bibliography that has been loaded
    #   from the style.
    # @raise all errors that `BibTeX::Bibliography` raises.
    #
    # @api user
    def load_data(file)
      @bibliography = BibTeX::Bibliography.open(file)
    end

    # Generates a citation for the `text` with given `id`. This method searches
    # the {#bibliography} for a `text` where `:key == id` and -- if it
    # happens to find one -- returns `@style.cite(text)`.
    #
    # @param [Symbol] id The unique identifier (key) set in the BibTeX file.
    # 
    # @raise [ArgumentError] if {#style} or {#bibliography} are `nil`, or if
    #   there is no text with given `id` in `bib`.
    #
    # @return [String] A citation for the given text.
    #
    # @api user
    def cite(id)
      check_attrs

      text = find_text(id)
      if text
        @style.cite(text)
      else
        raise ArgumentError.new "No text with id #{id} found."
      end
    end

    # Generates a bibliography entry for the `text` with given `id`. This method
    # searches the {#bibliography} for a `text` where `key == id` and -- if it
    # happens to find one -- returns `@style.bib(text)`.
    #
    # @param (see #cite)
    #
    # @raise (see #cite)
    #
    # @return [String] A bibliography entry for the given text.
    #
    # @api user
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
    # @return [Hash,nil] a `BibTeX::Entry` describing the text with given
    #   `id`, or nil if a text with given id was not found.
    def find_text(id)
      @bibliography[id]
    end

    # Checks if {#bibliography} and {#style} are defined (read: not `nil`).
    #
    # @raise [ArgumentError] if either is `nil`.
    def check_attrs
      raise ArgumentError.new "Please load a style first." unless @style
      raise ArgumentError.new "Please load bibliographic data first." unless \
        @bibliography
    end
  end
end
