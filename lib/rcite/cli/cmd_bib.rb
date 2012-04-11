module RCite
  module CLI
    # Command that creates a bibliography entry of a text. This provides the
    # command line interface to {RCite::Processor#bib}.
    class BibCommand < Command

      # This command's name. See {Command}.
      def self.name
        'bib'.freeze
      end

      # Creates an instance of this command.
      def initialize
        super
      end

      # Creates this command's `Slop` instance and sets up the options this
      # command accepts. See {Command}.
      #
      # @return [void]
      def setup_slop
        @slop = Slop.new do
          on :s, :style=, 'path to the style file', true, required: true
          on :b, :bib=, 'path to the BibTeX file', true, required: true
        end
      end

      # Creates a bibliography entry for the text specified on the command line.
      # See {Command}.
      #
      # In particular, this method validates all options (in addition to the
      # validation already performed by Slop) using {#validate_opts} and then
      # uses {RCite::Processor#bib} to generate a bibliography entry for the
      # specified text, handling any exceptions that are thrown by the
      # processor.
      #
      # @return [String] the generated bibliography entry.
      def run!
        validate_opts

        processor = RCite::Processor.new
        processor.load_style(@slop[:style])
        processor.load_data(@slop[:bib])
        begin
          return processor.bib(@cmdline[0])
        rescue ArgumentError => ex
          log.error(ex.message)
          exit 1
        end
      end

      # Validates the options passed to `rcite bib`. Checks if all files are
      # readable and if the user has specified the text ID to process. Logs
      # errors and exits otherwise.
      #
      # @return [void]
      def validate_opts
        Command.validate_file(@slop[:style])
        Command.validate_file(@slop[:bib])

        unless @cmdline[0]
          log.error("Please specify a text ID. See #{0} help cite for help.")
          exit 1
        end
      end

    end # class CiteCommand
  end # module CLI
end # module RCite
