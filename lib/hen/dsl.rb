#--
###############################################################################
#                                                                             #
# A component of hen, the Rake helper.                                        #
#                                                                             #
# Copyright (C) 2007-2009 University of Cologne,                              #
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

require 'nuggets/file/which'

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

    # Find a command that is executable and run it. Intended for
    # platform-dependent alternatives (Command A is not available?
    # Then try B instead).
    def execute(*commands)
      if command = File.which_command(commands)
        sh(command) { |ok, res|
          warn "Error while executing command: #{command} " <<
               "(return code #{res.exitstatus})" unless ok
        }
      else
        warn "Command not found: #{commands.join('; ')}"
      end
    end

    # Prepare the use of Rubyforge, optionally logging in right away.
    # Returns the RubyForge object.
    def init_rubyforge(login = true)
      require_rubyforge

      rf = RubyForge.new.configure
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

      require_rubyforge

      raise LocalJumpError, 'no block given' unless block

      block_args = [rf_config]
      block_args << lambda { |*args|
        init_rubyforge(args.empty? || args.first)
      } if block.arity > 1

      block[*block_args]
    end

    # Prepare the use of Gemcutter. Returns the Gemcutter (pseudo-)object.
    def init_gemcutter
      require_gemcutter(false)

      gc = Object.new

      def gc.push(gem)
        Gem::CommandManager.instance.run(['push', gem])
      end

      gc
    end

    # Encapsulates tasks targeting at Gemcutter, skipping those if
    # Gemcutter's 'push' command is not available. Yields an optional
    # proc to obtain Gemcutter objects from (via +call+; reaching out
    # to init_gemcutter).
    def gemcutter(&block)
      raise 'Skipping Gemcutter tasks' unless require_gemcutter

      raise LocalJumpError, 'no block given' unless block

      block_args = []
      block_args << lambda { |*args|
        init_gemcutter
      } if block.arity > 0

      block[*block_args]
    end

    private

    # Loads the Rubyforge library, giving a
    # nicer error message if it's not found.
    def require_rubyforge
      begin
        require 'rubyforge'
      rescue LoadError
        raise "Please install the 'rubyforge' gem first."
      end
    end

    # Loads the Gemcutter 'push' command, giving
    # a nicer error message if it's not found.
    def require_gemcutter(relax = true)
      require 'rubygems/command_manager'

      require 'commands/abstract_command'
      require 'commands/push'

      Gem::Commands::PushCommand
    rescue LoadError, NameError
      raise "Please install the 'gemcutter' gem first." unless relax
    end

  end

end
