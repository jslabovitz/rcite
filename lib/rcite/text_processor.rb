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
    # @return [Processor] this {TextProcessor}'s {Processor}.
    attr_accessor :command_processor

    # Regular Expression that describes a preprocessing command in the text.
    # Must have a group named `command` that contains a command as described in
    # {#process_command}. This regexp should not attempt to determine whether
    # the command syntax is correct.
    #
    # @example Command enclosed in '%%...%%' /%%(<command>.*)%%/m
    #
    # @return [Regexp] the preprocessing regexp.
    attr_accessor :preprocessing_regexp

    # @return [Regexp] The default value for {#preprocessing_regexp}.
    # 
    # @api user
    DEFAULT_PREPROCESSING_REGEXP = /%%\s*(?<command>.*?)\s*%%/m.freeze

    # Describes the syntax for commands. A command is the string inside the
    # {#preprocessing_regexp}. It includes the following information:
    #
    # 1. which command to call -- cite or bib
    # 2. the BibTeX key of the text to be cited/bib'd
    # 3. the page that should be cited (optional)
    # 4. additional fields as a YAML inline hash (optional)
    #
    # In other words, the syntax is:
    #
    # ```
    # command   ::== cite|bib key [page] [hash[, hash]*]
    # key       ::== anything_but_whitespace+
    # page      ::== anything_but_whitespace+|'anything+'
    # hash      ::== hash_key: 'hash_val'
    # hash_key  ::== hash_char+
    # hash_char ::== letter|number|_|-
    # hash_val  ::== anything_but_comma*
    # ```
    #
    # (Spaces stand for any whitespace.)
    #
    # @example Valid commands
    #   "cite rauber2008 25     title: 'new title', author: 'new author'"
    #   "bib  rauber_08  25--37                                         "
    #   "cite rauber-08         shorttitle: 'short title'               "
    #
    # @return [Regexp] the command regexp.
    #
    # @api user
    COMMAND_SYNTAX_REGEXP =
      /^((?<command>
             cite|bib
        )\s+)?+
        (?<key>
             [^\s]+
        )
        (\s+
         ((?<page>
             [^\s]+)
          |
          (?<page>
             '[^']+')
        ))?
        (\s+(?<fields>
             [a-zA-Z0-9\-_]+:\s*[^,]+
             (?:,\s*[a-zA-Z0-9\-_]+:\s*[^,]+)*
        ))?
      $/xm.freeze

    # Creates a new {TextProcessor}. {#command_processor} is initialised with
    # a new {Processor}.
    def initialize
      @command_processor = Processor.new
      @preprocessing_regexp = DEFAULT_PREPROCESSING_REGEXP
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
      text.gsub(@preprocessing_regexp) do |m|
        process_command($~[:command])
      end
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
      cmd = nil
      result = []
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

        fields_hash = {} # will contain additional (quasi-)BibTeX fields

        fields_hash[:thepage] = page if page

        if fields
          begin
            hsh = YAML.load("{ #{fields} }")
          rescue SyntaxError
            result << '%%SYNTAX ERROR: invalid additional fields%%'
            next
          end

          hsh2 = {}
          hsh.each_pair do |k,v|
            hsh2[k.to_sym] = v
          end

          fields_hash.merge!(hsh2)
        end

        a_each = @command_processor.style.around(:each, cmd)

        result <<
          a_each[0].to_s +
          @command_processor.send(cmd, key, fields_hash).to_s +
          a_each[1].to_s
      end

      a_all = @command_processor.style.around(:all, cmd)
      cmd_plural = (cmd.to_s + 's').to_sym # :cite -> :cites, :bib -> :bibs
      between = @command_processor.style.between(cmd_plural).to_s
      
      a_all[0].to_s + result.join(between) + a_all[1].to_s
    end

  end # class TextProcessor
end # module RCite
