require 'yaml'

module RCite
  # Processes a file, replacing certain preprocessor commands with citations
  # or bibliography entries.
  #
  # The `TextProcessor` extracts RCite commands from a text by searching for
  # a certain regular expression and processes each command according to the
  # rules described in `#process_command`. Its main method is {#process_text}.
  class TextProcessor

    # The processor that creates the actual citations or bibliography entries.
    # {TextProcessor} basically just parses the preprocessing commands and
    # then calls {Processor#cite} or {Processor#bib} with the extracted
    # parameters.
    #
    # Must have a group named `command` that contains a command which
    # {#process_command} can use.
    #
    # @return [Processor] this {TextProcessor}'s {Processor}.
    attr_accessor :command_processor

    # Regular Expression that describes a preprocessing command in the text.
    # This regexp should not attempt to determine whether the command syntax
    # is correct. It must not match text that is matched by
    # {#bibliography_regexp}.
    #
    # Must have a group named `command` that contains a command which
    # {#process_command} can use.
    #
    # @return [Regexp] the preprocessing regexp.
    attr_accessor :preprocessing_regexp

    # Regular expression that describes the special `bibliography` preprocessing
    # command. This regexp should not attempt to determine whether the command
    # syntax is correct.
    #
    # @return [Regexp] the bibliography regexp.
    attr_accessor :bibliography_regexp

    # @return [Regexp] Default value for {#preprocessing_regexp}.
    # 
    # @api user
    DEFAULT_PREPROCESSING_REGEXP =
      /%%\s*(?<command>(cite|bib)\s+[^%]*)%%/m.freeze

    # @return [Regexp] Default value for {#bibliography_regexp}.
    #
    # @api user
    DEFAULT_BIBLIOGRAPHY_REGEXP  =
      /%%\s*(?<command>bibliography[^%]*)%%/m.freeze

    # Generates the regular expression that is used to parse commands. This
    # method always returns the exact same result and therefore behaves much
    # like a constant. It is only there to make the regexp more readable and
    # its various parts more transparent.
    #
    # For command syntax and such, see {COMMAND_SYNTAX_REGEXP}.
    #
    # @return [Regexp] A regular expression that describes the syntax of
    #   preprocessing commands.
    def self.command_syntax_regexp
      cmd           = /(?<command>bib|cite)/
      key           = /(?<key>[^\s]+)/
      lit_string    = /(?:"(?:[^"]|(?:(?<=\\)"))+")/ # matches '"s"' and '"s\""'
      page          = /(?<page>(?:[^\s]+)|#{lit_string})/
      hash_key      = /[a-zA-Z0-9_\-]+/
      hash_val      = /(?:(?:[^,]+)|#{lit_string})/
      hash_elem     = /#{hash_key}:\s*#{hash_val}/
      hash          = /(?<fields>#{hash_elem}(?:\s*,\s*(?:#{hash_elem}))*)/
      result        = /^\s*
                       (?:#{cmd}\s+)?
                       #{key}
                       (?:\s+#{page})?
                       (?:\s+#{hash})?
                       \s*$/mx
    end

    # Describes the syntax for commands. A command is the string inside the
    # {#preprocessing_regexp}. It includes the following information:
    #
    # 1. which command to call -- cite or bib. Required for the first command
    #    in a preprocessing directive, optional for any commands that follow.
    # 2. the BibTeX key of the text to be cited/bib'd
    # 3. the page that should be cited (optional)
    # 4. additional fields as a YAML inline hash (optional)
    #
    # In other words, the syntax is:
    #
    # ```
    # command   ::== cite|bib key [page] [hash[, hash]*]
    # key       ::== anything_but_whitespace+
    # page      ::== anything_but_whitespace+|"anything_but_quote+"
    # hash      ::== hash_key: hash_val+|"anything_but_quote+"
    # hash_key  ::== hash_char+
    # hash_char ::== letter|number|_|-
    # hash_val  ::== anything_but_comma*|"anything_but_quote+"
    # ```
    #
    # Spaces stand for any whitespace. Strings that are enclosed in quotation 
    # marks can use `'\"'` to mask them.
    #
    # @example Valid commands
    #   'cite rauber2008 25        title: "new, title", author: new author'
    #   'bib  rauber_08  25--37                                           '
    #   'cite rauber-08            shorttitle: short title                '
    #   'cite rauber-08  "§2 Rn.2" shorttitle: short title                '
    #
    # @return [Regexp] the command regexp.
    #
    # @api user
    COMMAND_SYNTAX_REGEXP = self.command_syntax_regexp.freeze

    # Creates a new {TextProcessor}. {#command_processor} is initialised with
    # a new {Processor}.
    def initialize
      @command_processor    = Processor.new
      @preprocessing_regexp = DEFAULT_PREPROCESSING_REGEXP
      @bibliography_regexp  = DEFAULT_BIBLIOGRAPHY_REGEXP
      @cited_texts = []
    end

    # Reads the contents of `file` and processes them, returning the processed
    # text. Convenience wrapper for {#process_text}.
    #
    # @param [String,IO] file Path to the file or `IO` object.
    #
    # @return The processed file contents. See {#process_text}.
    #
    # @api user
    def process_file(file)
      process_text(File.read(file))
    end

    # Replaces every occurence of {#preprocessing_regex} in `text` with the
    # output of {#process_command}. Only the group named `command` from
    # `preprocessing_regexp` is passed to `process_command` as a parameter.
    #
    # @param [String] text Any string.
    #
    # @return [String] The original `text` with all preprocessing commands
    #   replaced by citations or bibliography entries. If no preprocessing
    #   commands were found, this is the unchanged `text`.
    #
    # @api user
    def process_text(text)
      @cited_texts = []
      result = text.dup
      result.gsub!(@preprocessing_regexp) do |m|
        process_command($~[:command])
      end
      result.gsub!(@bibliography_regexp) do |m|
        generate_bibliography
      end
      @cited_texts = nil
      result
    end

    # Replaces a preprocessing command with the corresponding citation or
    # bibliography entry. Extracts command parameters from `command` using
    # {COMMAND_SYNTAX_REGEXP} and executes the corresponding command of the
    # {#command_processor}.
    #
    # If any errors occur while parsing the `command` or generating the
    # citation/bibliography entry, this method returns a string indicating that
    # there were errors.
    #
    # @param [String] command The command that should be parsed.
    #
    # @return [String] The citation/bibliography entry, or a string indicating
    #   that an error occured.
    def process_command(command)
      style = @command_processor.style
      cmd = nil
      result = []

      # subcommands are separated by the pipe symbol
      command.split("|").each do |subcommand|
        m = COMMAND_SYNTAX_REGEXP.match(subcommand)
        unless m # unless we have a syntactically valid command
          result << '%%SYNTAX ERROR%%' 
          next
        end

        cmd ||= m[:command] # the command is parsed only for the first subcmd
        return '%%SYNTAX ERROR: no command specified%%' unless cmd
        cmd = cmd.to_sym

        key, page, fields = m[:key], m[:page], m[:fields]
        page.gsub!(/^"(.*?)"$/m, '\1') if page

        result << generate_cite_bib(cmd, key, page, fields)

        @cited_texts << key if cmd == :cite
      end # each subcommand

      a_all = style.around(:all, cmd)
      cmd_plural = (cmd.to_s + 's').to_sym # :cite -> :cites, :bib -> :bibs
      between = style.between(cmd_plural).to_s

      a_all[0].to_s + result.join(between) + a_all[1].to_s
    end #process_command

    # BEGIN PRIVATE ############################################################

    private

    # Generates bibliography entries for each text that has been cited in
    # preprocessing mode. Takes the separators given by {Style#around} and
    # {Style#between} into account.
    #
    # @return [String] A complete printable bibliography.
    def generate_bibliography
      style = @command_processor.style
      result = []
      @cited_texts.each do |key|
        result << generate_cite_bib(:bib, key, nil, nil)
      end

      a_all = style.around(:all, :bibs)
      between = style.between(:bibs).to_s
      a_all[0].to_s + result.join(between) + a_all[1].to_s
    end #generate_bibliography

    # Generates a citation or bibliography entry.
    #
    # @param [:bib,:cite] cmd Determines whether a citation or a bibliography
    #   entry is created.
    # @param [String] key BibTeX ID of the text that should be cited/bib'd.
    # @param [String] page Value that should be assigned to the `thepage`
    #   (quasi-)BibTeX field before citing/bib'ing. May be `nil`.
    # @param [Hash<Symbol, String>] fields Additional BibTeX fields. Keys are
    #   BibTeX field names, values are their values. May be `nil`.
    def generate_cite_bib(cmd, key, page, fields)
      style = @command_processor.style
      fields_hash = {} # will contain additional (quasi-)BibTeX fields

      fields_hash[:thepage] = page if page

      if fields
        begin
          hsh = YAML.load("{ #{fields} }")
        rescue SyntaxError
          return '%%SYNTAX ERROR: invalid additional fields%%'
        end

        hsh2 = {}
        hsh.each_pair do |k,v|
          hsh2[k.to_sym] = v
        end

        fields_hash.merge!(hsh2)
      end

      a_each = style.around(:each, cmd)

      a_each[0].to_s +
        @command_processor.send(cmd, key, fields_hash).to_s +
        a_each[1].to_s
    end #generate_cite_bib

  end # class TextProcessor
end # module RCite
