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

    # The Hen configuration.
    def config
      config = Hen.config

      # always return a duplicate for a value, hence making the
      # configuration immutable
      def config.[](key)
        fetch(key).dup
      rescue IndexError
        {}
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

    # Encapsulates tasks targeting at Rubyforge, skipping those if no
    # Rubyforge project is defined. Yields the Rubyforge configuration
    # hash and, optionally, a proc to obtain RubyForge objects from (via
    # +call+; reaching out to init_rubyforge).
    def rubyforge(&block)
      rf_config  = config[:rubyforge]
      rf_project = rf_config[:project]

      raise 'Skipping Rubyforge tasks' if rf_project.nil? || rf_project.empty?
      raise LocalJumpError, 'no block given' unless block

      require 'rubyforge'

      block_args = [rf_config]

      block_args << lambda { |*args|
        init_rubyforge(args.empty? || args.first)
      } if block.arity > 1

      block[*block_args]
    end

  end

end
