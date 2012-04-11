require 'rcite/cli/command'

module RCite
  # The classes in this module provide RCite's command line interface.
  module CLI
    # Main class of the RCite command line interface.
    class Main

      # Runs the command specified as the first argument on the command line.
      # If no command is specified or the given command does not exist, prints
      # an error message and exits.
      #
      # @param [Array] An array of strings, where each element represents a
      #   command line parameter.
      # @return [void]
      def self.run(cmdline = ARGV)
        cmd = cmdline[0]
        log.error "Please specify a command. See #{$0} help." unless cmd
        cmdline.shift
        
        # Determine the command class. Commands are each represented by a class
        # whose superclass is RCite::CLI::Command.
        cmd_class = RCite::CLI.constants.
          collect { |c| RCite::CLI.const_get(c) }.
          select  { |c| c.superclass == RCite::CLI::Command &&
                        c.name == cmd     }

        # Run the command or display an error if no such command was found.
        if cmd_class[0]
          puts cmd_class[0].new.run(cmdline)
        else
          log.error "Command not found: #{cmd}. See #{File.basename($0)} help"
        end
      end

    end # class Main
  end # module CLI
end # module RCite
