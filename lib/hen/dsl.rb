#--
###############################################################################
#                                                                             #
# A component of hen, the Rake helper.                                        #
#                                                                             #
# Copyright (C) 2007-2008 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50932 Cologne, Germany                              #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# hen is free software; you can redistribute it and/or modify it under the    #
# terms of the GNU General Public License as published by the Free Software   #
# Foundation; either version 3 of the License, or (at your option) any later  #
# version.                                                                    #
#                                                                             #
# hen is distributed in the hope that it will be useful, but WITHOUT ANY      #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more       #
# details.                                                                    #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with hen. If not, see <http://www.gnu.org/licenses/>.                       #
#                                                                             #
###############################################################################
#++

class Hen

  # Some helper methods for use inside of a Hen definition.
  module DSL

    extend self

    # The Hen configuration. Raises HenError::ConfigRequired
    # if a required configuration is missing.
    def config
      config = Hen.config

      # always return a duplicate for a value, hence making the
      # configuration immutable; raise if config is missing
      def config.[](key)
        raise HenError::ConfigRequired.new(key) unless has_key?(key)

        fetch(key).dup
      end

      config
    end

    # Define task +t+, but overwrite any existing task of that name!
    # (Rake usually just adds them up)
    def task!(t, &block)
      Rake.application.instance_variable_get(:@tasks).delete(t.to_s)
      task(t, &block)
    end

    # Execute a series of commands until one of them succeeds. Intended for
    # platform-dependent alternatives (Command A is not available? Then try
    # B instead).
    #
    # TODO: This won't detect cases where a command is actually available,
    # but simply fails.
    def execute(*commands)
      commands.each { |command|
        ok, res = sh(command) { |ok, res| [ok, res] }
        break if ok

        warn "Error while executing command (return code #{res.exitstatus})"
      }
    end

    # Prepare the use of Rubyforge, optionally logging in right away.
    # Returns the RubyForge object.
    def init_rubyforge(login = true)
      require 'rubyforge'

      rf = RubyForge.new
      rf.login if login

      rf
    end

  end

end
