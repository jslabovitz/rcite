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
  #
  # @todo Implement the shortcuts and BibTeX file loading. 
  class Processor

    # The style that is used to turn bibliographic data gathered from a
    # (BibTeX) file to actual citations/bibliographic entries. Should
    # usually be a subclass of {RCite::Style}. Can be `nil` if no style
    # has been loaded yet.
    attr_accessor :style
    
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

  end
end
