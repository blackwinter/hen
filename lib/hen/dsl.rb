#--
###############################################################################
#                                                                             #
# A component of hen, the Rake helper.                                        #
#                                                                             #
# Copyright (C) 2007-2011 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
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

    # Prepare the use of RubyForge, optionally logging in right away.
    # Returns the RubyForge object.
    def init_rubyforge(login = true)
      require_rubyforge

      rf = RubyForge.new.configure
      rf.login if login

      rf
    end

    # Encapsulates tasks targeting at RubyForge, skipping those if no
    # RubyForge project is defined. Yields the RubyForge configuration
    # hash and, optionally, a proc to obtain RubyForge objects from (via
    # +call+; reaching out to init_rubyforge).
    def rubyforge(&block)
      rf_config  = config[:rubyforge]
      rf_project = rf_config[:project]

      raise 'Skipping RubyForge tasks' if rf_project.nil? || rf_project.empty?

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

    def git
      raise 'Skipping Git tasks' unless File.directory?('.git')

      yield init_git
    end

    def init_git
      class << git = Object.new

        instance_methods.each { |method|
          undef_method(method) unless method =~ /\A__/
        }

        def method_missing(cmd, *args)
          sh 'git', cmd.to_s.tr('_', '-'), *args
        end

        #alias_method :sh, :system

        def run(*args)
          %x{#{args.unshift('git').join(' ')}}
        end

        def remote_for_branch(branch)
          run(:branch, '-r')[/(\S+)\/#{Regexp.escape(branch)}$/, 1]
        end

        def url_for_remote(remote)
          run(:remote, '-v')[/\A#{Regexp.escape(remote)}\s+(\S+)/, 1]
        end

        def find_remote(regexp)
          run(:remote, '-v').split($/).grep(regexp).first
        end

        def easy_clone(url, dir = '.', remote = 'origin')
          clone '-n', '-o', remote, url, dir
        end

        def checkout_remote_branch(remote, branch = 'master')
          checkout '-b', branch, "#{remote}/#{branch}"
        end

        def add_and_commit(msg)
          add '.'
          commit '-m', msg
        end

      end

      git
    end

    private

    # Loads the RubyForge library, giving a
    # nicer error message if it's not found.
    def require_rubyforge
      begin
        require 'rubyforge'
      rescue LoadError
        raise "Please install the `rubyforge' gem first."
      end
    end

    # Loads the Gemcutter 'push' command, giving
    # a nicer error message if it's not found.
    def require_gemcutter(relax = true)
      begin
        require 'rubygems/command_manager'
        require 'rubygems/commands/push_command'
      rescue LoadError
        # rubygems < 1.3.6, gemcutter < 0.4.0
        require 'commands/abstract_command'
        require 'commands/push'
      end

      Gem::Commands::PushCommand
    rescue LoadError, NameError
      raise "Please install the `gemcutter' gem first." unless relax
    end

  end

end
