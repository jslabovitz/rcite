require 'logger'

module RCite
  # Custom logger class for RCite. Uses `::Logger` as a backend.
  class Logger < ::Logger

    private_class_method :new

    # Creates a new {Logger}. The program name is set to 'rcite' automatically.
    #
    # New loggers use a short message format suitable for console output. If you
    # want to log to a file, it is recommended that you change the formatting,
    # especially to include date and time. See the stdlib documentation of
    # `formatter=`.
    #
    # For explanations of what the parameters mean, see the documentation
    # of `::Logger`.
    def initialize(device = STDOUT, shift_age = 0, shift_size = 1048576)
      super(device, shift_age, shift_size)
      @progname = 'rcite'
      @formatter = proc do |sev, date, prog, msg|
        "#{prog} #{sev}: #{msg}\n"
      end
    end

    # Returns the global {Logger} instance used throughout the programme.
    #
    # @return [Logger] the global instance.
    def self.instance
      @@instance ||= new
    end

    # Logs an exception, including its backtrace, with severity level `ERROR`.
    #
    # @param [Exception] exception Any exception. More specifically, any object
    #   with methods `#message` and `#backtrace`.
    # @return [void]
    def ex(exception)
      error "#{exception.class.to_s}: #{exception.message}\n"
      error "Stack trace:" +
        exception.backtrace.map {|elem| "\n\t#{elem}" }.join + "\n"
    end

  end
end

# Returns the global {RCite::Logger} instance that is used for logging
# throughout the programme.
#
# @return [RCite::Logger] the global logger.
def log
  RCite::Logger.instance
end
