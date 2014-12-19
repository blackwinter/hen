class Hen

  module Version

    MAJOR = 0
    MINOR = 8
    TINY  = 1

    class << self

      # Returns array representation.
      def to_a
        [MAJOR, MINOR, TINY]
      end

      # Short-cut for version string.
      def to_s
        to_a.join('.')
      end

      # Pessimistic version constraint.
      def pessimistic_requirement
        ["~> #{MAJOR}.#{MINOR}", ">= #{to_s}"]
      end

    end

  end

  VERSION = Version.to_s

end
