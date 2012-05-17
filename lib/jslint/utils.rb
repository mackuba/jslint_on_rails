module JSLint
  VERSION = "1.1.1"

  module Utils
    class << self
      def pluralize(amount, word)
        s = "s" unless amount == 1
        "#{amount} #{word}#{s}"
      end

      def paths_from_command_line(field)
        argument = ENV[field] || ENV[field.upcase]
        argument && argument.split(/,/)
      end
    end
  end
end
