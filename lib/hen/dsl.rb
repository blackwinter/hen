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
# terms of the GNU Affero General Public License as published by the Free     #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# hen is distributed in the hope that it will be useful, but WITHOUT ANY      #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for     #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with hen. If not, see <http://www.gnu.org/licenses/>.                 #
#                                                                             #
###############################################################################
#++

require 'hen'
require 'nuggets/file/which'

class Hen

  # Some helper methods for use inside of a Hen definition.

  module DSL

    extend self

    # The Hen configuration.
    def config
      extend_object(Hen.config.dup) {
        # Always return a duplicate for a value,
        # hence making the configuration immutable
        def [](key)  # :nodoc:
          fetch(key).dup
        rescue IndexError
          {}
        end
      }
    end

    # Determine the project name from +gem_config+'s <tt>:name</tt>,
    # or +rf_config+'s <tt>:package</tt> or <tt>:project</tt>.
    def project_name(rf_config = {}, gem_config = {})
      gem_config[:name] || rf_config[:package] || rf_config[:project]
    end

    # Define task +t+, but overwrite any existing task of that name!
    # (Rake usually just adds them up.)
    def task!(t, *args)
      Rake.application.instance_variable_get(:@tasks).delete(t.to_s)
      task(t, *args, &block_given? ? Proc.new : nil)
    end

    # Return true if task +t+ is defined, false otherwise.
    def have_task?(t)
      Rake.application.instance_variable_get(:@tasks).has_key?(t.to_s)
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

    # Clean up the file lists in +args+ by removing duplicates and either
    # deleting any files that are not managed by the source code management
    # system (untracked files) or, if the project is not version-controlled
    # or the SCM is not recognized, deleting any files that don't exist.
    #
    # The return value indicates whether source control is in effect.
    #
    # Currently supported SCM's (in that order): Git[http://git-scm.com],
    # SVN[http://subversion.tigris.org].
    def mangle_files!(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}

      managed_files = [:git, :svn].find { |scm|
        res = send(scm) { |scm_obj| scm_obj.managed_files }
        break res if res
      } if !options.has_key?(:managed) || options[:managed]

      args.each { |files|
        files ? files.uniq! : next

        if managed_files
          files.replace(files & managed_files)
        else
          files.delete_if { |file| !File.readable?(file) }
        end
      }

      !!managed_files
    end

    # Encapsulates tasks targeting at RubyForge, skipping those if no
    # RubyForge project is defined. Yields the RubyForge configuration
    # hash and, optionally, a proc to obtain RubyForge objects from (via
    # +call+; reaching out to #init_rubyforge).
    def rubyforge
      rf_config  = config[:rubyforge]
      rf_project = rf_config[:project]

      if rf_project && !rf_project.empty? && have_rubyforge?
        rf_config[:package] ||= rf_project

        call_block(Proc.new, rf_config) { |*args|
          init_rubyforge(args.empty? || args.first)
        }
      else
        skipping 'RubyForge'
      end
    end

    # Encapsulates tasks targeting at RubyGems.org, skipping those if
    # RubyGem's 'push' command is not available. Yields an optional
    # proc to obtain RubyGems (pseudo-)objects from (via +call+;
    # reaching out to #init_rubygems).
    def rubygems
      if have_rubygems?
        call_block(Proc.new) { |*args| init_rubygems }
      else
        skipping 'RubyGems'
      end
    end

    # DEPRECATED: Use #rubygems instead.
    def gemcutter
      warn "#{self}#gemcutter is deprecated; use `rubygems' instead."
      rubygems(&block_given? ? Proc.new : nil)
    end

    # Encapsulates tasks targeting at Git, skipping those if the current
    # project us not controlled by Git. Yields a Git object via #init_git.
    def git
      have_git? ? yield(init_git) : skipping('Git')
    end

    # Encapsulates tasks targeting at SVN, skipping those if the current
    # project us not controlled by SVN. Yields an SVN object via #init_svn.
    def svn
      have_svn? ? yield(init_svn) : skipping('SVN')
    end

    private

    # Warn about skipping tasks for +name+ (if +do_warn+ is true) and return nil.
    def skipping(name, do_warn = Hen.verbose)
      warn "Skipping #{name} tasks." if do_warn
      nil
    end

    # Warn about missing library +lib+ (if +do_warn+ is true) and return false.
    def missing_lib(lib, do_warn = $DEBUG)
      warn "Please install the `#{lib}' library for additional tasks." if do_warn
      false
    end

    # Loads the RubyForge library, giving a
    # nicer error message if it's not found.
    def have_rubyforge?
      require 'rubyforge'
      true
    rescue LoadError
      missing_lib 'rubyforge'
    end

    # Loads the RubyGems +push+ command, giving
    # a nicer error message if it's not found.
    def have_rubygems?
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
      missing_lib 'gemcutter'
    end

    # Checks whether the current project is managed by Git.
    def have_git?
      File.directory?('.git')
    end

    # Checks whether the current project is managed by SVN.
    def have_svn?
      File.directory?('.svn')
    end

    # Prepare the use of RubyForge, optionally logging
    # in right away. Returns the RubyForge object.
    def init_rubyforge(login = true)
      return unless have_rubyforge?

      rf = RubyForge.new.configure
      rf.login if login

      rf
    end

    # Prepare the use of RubyGems.org. Returns the RubyGems
    # (pseudo-)object.
    def init_rubygems
      pseudo_object {
        def method_missing(cmd, *args)  # :nodoc:
          run(cmd, *args)
        end

        def run(cmd, *args)  # :nodoc:
          Gem::CommandManager.instance.run([cmd.to_s.tr('_', '-'), *args])
        end
      } if have_rubygems?
    end

    # Prepare the use of Git. Returns the Git (pseudo-)object.
    def init_git
      pseudo_object {
        def method_missing(cmd, *args)  # :nodoc:
          options = args.last.is_a?(Hash) ? args.pop : {}
          options[:verbose] = Hen.verbose unless options.has_key?(:verbose)

          sh('git', cmd.to_s.tr('_', '-'), *args << options)
        end

        def run(cmd, *args)  # :nodoc:
          %x{git #{args.unshift(cmd.to_s.tr('_', '-')).join(' ')}}
        end

        def remote_for_branch(branch)  # :nodoc:
          run(:branch, '-r')[%r{(\S+)/#{Regexp.escape(branch)}$}, 1]
        end

        def url_for_remote(remote)  # :nodoc:
          run(:remote, '-v')[%r{^#{Regexp.escape(remote)}\s+(\S+)}, 1]
        end

        def find_remote(regexp)  # :nodoc:
          run(:remote, '-v').split($/).grep(regexp).first
        end

        def easy_clone(url, dir = '.', remote = 'origin')  # :nodoc:
          clone '-n', '-o', remote, url, dir
        end

        def checkout_remote_branch(remote, branch = 'master')  # :nodoc:
          checkout '-b', branch, "#{remote}/#{branch}"
        end

        def add_and_commit(msg)  # :nodoc:
          add '.'
          commit '-m', msg
        end

        def managed_files  # :nodoc:
          run(:ls_files).split($/)
        end
      } if have_git?
    end

    # Prepare the use of SVN. Returns the SVN (pseudo-)object.
    def init_svn
      pseudo_object {
        def method_missing(cmd, *args)  # :nodoc:
          options = args.last.is_a?(Hash) ? args.pop : {}
          options[:verbose] = Hen.verbose unless options.has_key?(:verbose)

          sh('svn', cmd.to_s.tr('_', '-'), *args << options)
        end

        def run(cmd, *args)  # :nodoc:
          %x{svn #{args.unshift(cmd.to_s.tr('_', '-')).join(' ')}}
        end

        def version  # :nodoc:
          %x{svnversion}[/\d+/]
        end

        def managed_files  # :nodoc:
          run(:list, '--recursive').split($/)
        end
      } if have_svn?
    end

    # Extend +object+ with given +blocks+.
    def extend_object(object, *blocks)
      blocks << Proc.new if block_given?

      singleton_class = class << object; self; end

      blocks.compact.reverse_each { |block|
        singleton_class.class_eval(&block)
      }

      object
    end

    # Create a (pseudo-)object.
    def pseudo_object
      extend_object(Object.new, block_given? ? Proc.new : nil) {
        instance_methods.each { |method|
          undef_method(method) unless method =~ /\A__/
        }
      }
    end

    # Calls block +block+ with +args+, appending an
    # optional passed block if requested by +block+.
    def call_block(block, *args)
      args << Proc.new if block.arity > args.size
      block[*args]
    end

  end

end
