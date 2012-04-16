module RCite
  class Style

    # @return [Array<Option>] List of {Option}s that determine the behaviour
    #   of `Style` methods and provide instructions for other class that deal
    #   with styles (most notably the {TextProcessor}).
    #
    #   For each of these options, a helper method named `_<option name>` is
    #   added to the {Style} class. Users can set options by calling
    #   `_<option name>(value...)` or get the value(s) of an option using
    #   the plain `_<option name>`.
    #
    #   TODO document individual options
    OPTIONS = [
      Option.new(:ordering,         default:     :last_first,
                                    good_values: [:last_first, :first_last],
                                    validator:   Proc.new { false },
                                    allow_nil:   false                        ),
      Option.new(:delim,            default:     '; ',
                                    transformer: String                       ),
      Option.new(:et_al,            default:     3,
                                    transformer: Integer                      ),
      Option.new(:et_al_string,     default:     'et al.',
                                    transformer: Integer                      ),
      Option.new(:around_each_bib,  transformer: String,
                                    default:     []                           ),
      Option.new(:around_each_cite, transformer: String,
                                    default:     []                           ),
      Option.new(:around_all_bibs,  transformer: String,
                                    default:     []                           ),
      Option.new(:around_all_cites, transformer: String,
                                    default:     []                           ),
      Option.new(:between_bibs,     transformer: String,
                                    default:     "\n"                         ),
      Option.new(:between_cites,    transformer: String,
                                    default:     "; "                         )
    ]

    OPTIONS.each do |o|
      define_method("_#{o.name}".to_sym) do |*args|
        optname = __method__.to_s.sub(/^_/, '').to_sym
        opt = instance_variable_get(:@opts)[optname]
        if args.empty?
          opt.get
        else
          opt.set(*args)
        end
      end
    end

  end # Style
end # RCite
