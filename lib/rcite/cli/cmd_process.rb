module RCite
  module CLI
    # Frontend to the {RCite::TextProcessor}.
    class ProcessCommand < Command

      # This command's name. See {Command}.
      def self.name
        'process'.freeze
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

      # Processes the file specified on the command line. In particular, this
      # method
      #
      # 1. performs additional options validation via {#validate_opts};
      # 2. loads the style and bibliography specified on the command line;
      # 3. processes the file and returns the result.
      #
      # @return [String] the processed file content. See
      # {RCite::TextProcessor#process_text} for details.
      def run!
        validate_opts

        processor = RCite::TextProcessor.new
        processor.command_processor.load_style(@slop[:style])
        processor.command_processor.load_data( @slop[:bib]  )
        processor.process_file(@cmdline[0])
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
