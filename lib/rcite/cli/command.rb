module RCite
  module CLI
    # Represents an RCite command. RCite uses the same structure for its CLI
    # as `gem`, `git` etc., i.e. it has multiple commands that correspond to
    # various actions. For example, `rcite cite` will cite a text, while
    # `rcite bib` will create a bibliography entry.
    #
    # This class provides helper methods that establish a framework for
    # individual commands. Each of those has its own class that is a child of
    # this class.
    #
    # Child classes are expected to implement the following methods:
    #
    # - ::name -- Returns the command's name. See class method {::name}.
    # - #setup_slop -- Creates a new `Slop` instance and defines the options
    #   that may be used with the command. Sets the `@slop` instance variable
    #   accordingly.
    # - #run! -- Runs the command after all options have been parsed and their
    #   validity has been checked.
    #
    # @abstract
    class Command

      require 'slop'

      # @return [String] the command's name. This is used to identify the
      #   command the user is calling. For example, RCite will search for
      #   a command with name 'cite' when called as `rcite cite`. Individual
      #   commands must override this variable.
      def self.name
        nil
      end

      # Calls the child's `setup_slop` method. See {Command} for details.
      def initialize
        setup_slop # must be defined by child classes
      end

      # Parses the given `cmdline` as a command line array (usually `ARGV`)
      # and runs the child's `run!` method. See {Command} for details.
      #
      # @param [Array] cmdline An array of strings, one for each element of
      #   the command line. You will usually want to use `ARGV` here.
      # @return [void]
      def run(cmdline)
        @cmdline = cmdline
        begin
          @slop.parse!(cmdline)
        rescue Slop::MissingOptionError => ex
          log.error(ex.message)
          exit 1
        end
        run! # must be defined by child classes
      end

      # Returns a help message for the individual command.
      #
      # @return [String] a help message with usage information and a summary
      #   of the command's options.
      def help
        @slop.help
      end

    end # module Command
  end # module CLI
end # module RCite
