#--
###############################################################################
#                                                                             #
# A component of hen, the Rake helper.                                        #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013-2014 Jens Wille                                          #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
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

require 'nuggets/file/which'
require 'nuggets/object/singleton_class'

class Hen

  # Some helper methods for use inside of a Hen definition.

  module DSL

    extend self
    extend Rake::DSL if Rake.const_defined?(:DSL)

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
    def task!(t, *args, &block)
      Rake.application.instance_variable_get(:@tasks).delete(t.to_s)
      task(t, *args, &block)
    end

    # Return true if task +t+ is defined, false otherwise.
    def have_task?(t)
      Rake.application.instance_variable_get(:@tasks).key?(t.to_s)
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
      } if !options.key?(:managed) || options[:managed]

      args.compact.each { |files|
        files.uniq!

        if managed_files
          files.replace(files & managed_files)
        else
          files.delete_if { |file| !File.readable?(file) }
        end
      }

      !!managed_files
    end

    # Set +options+ on +object+ by calling the corresponding setter method
    # for each option; warns about illegal options. Optionally, use +type+
    # to describe +object+ (defaults to its class).
    def set_options(object, options, type = object.class)
      options.each { |option, value|
        if object.respond_to?(setter = "#{option}=")
          object.send(setter, value)
        else
          warn "Unknown #{type} option: #{option}"
        end
      }
    end

    # Map +options+ hash to array of command line arguments.
    def map_options(options)
      options.map { |option, value|
        option = '--' << option.to_s.tr('_', '-')

        case value
          when Array  then value.map { |_value| [option, _value] }
          when String then [option, value]
          else value ? option : nil
        end
      }.compact.flatten
    end

    # Encapsulates tasks targeting at RubyForge, skipping those if no
    # RubyForge project is defined. Yields the RubyForge configuration
    # hash and, optionally, a proc to obtain RubyForge objects from (via
    # +call+; reaching out to #init_rubyforge).
    def rubyforge(&block)
      rf_config  = config[:rubyforge]
      rf_project = rf_config[:project]

      if rf_project && !rf_project.empty? && have_rubyforge?
        rf_config[:package] ||= rf_project

        call_block(block, rf_config) { |*args|
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
    def rubygems(&block)
      if have_rubygems?
        call_block(block) { |*args| init_rubygems }
      else
        skipping 'RubyGems'
      end
    end

    # DEPRECATED: Use #rubygems instead.
    def gemcutter(&block)
      warn "#{self}#gemcutter is deprecated; use `rubygems' instead."
      rubygems(&block)
    end

    # Encapsulates tasks targeting at Git, skipping those if the current
    # project is not controlled by Git. Yields a Git object via #init_git.
    def git
      have_git? ? yield(init_git) : skipping('Git')
    end

    # Encapsulates tasks targeting at SVN, skipping those if the current
    # project is not controlled by SVN. Yields an SVN object via #init_svn.
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
      missing_lib 'rubygems (gemcutter)'
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
      return unless have_rubygems?

      pseudo_object {
        def method_missing(cmd, *args)  # :nodoc:
          run(cmd, *args)
        end

        def run(cmd, *args)  # :nodoc:
          Gem::CommandManager.instance.run([cmd.to_s.tr('_', '-'), *args])
        end
      }
    end

    # Prepare the use of Git. Returns the Git (pseudo-)object.
    def init_git
      return unless have_git?

      pseudo_object {
        def method_missing(cmd, *args)  # :nodoc:
          options = args.last.is_a?(Hash) ? args.pop : {}
          options[:verbose] = Hen.verbose unless options.key?(:verbose)

          DSL.send(:sh, 'git', cmd.to_s.tr('_', '-'), *args << options)
        end

        def run(cmd, *args)  # :nodoc:
          %x{git #{args.unshift(cmd.to_s.tr('_', '-')).join(' ')}}
        end

        def remote_for_branch(branch, default = 'origin')  # :nodoc:
          remotes = run(:branch, '-r').scan(%r{(\S+)/#{Regexp.escape(branch)}$})
          remotes.flatten!

          if env_remote = ENV['HEN_REMOTE']
            env_remote if remotes.include?(env_remote)
          else
            remotes.include?(default) ? default : remotes.first
          end
        end

        def url_for_remote(remote)  # :nodoc:
          run(:remote, '-v')[%r{^#{Regexp.escape(remote)}\s+(\S+)}, 1]
        end

        def find_remote(regexp, default = 'origin')  # :nodoc:
          remotes = run(:remote, '-v').split($/).grep(regexp)
          remotes.map! { |x| x.split[0..1] }

          if env_remote = ENV['HEN_REMOTE']
            remotes.assoc(env_remote)
          else
            remotes.assoc(default) || remotes.first
          end
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
      }
    end

    # Prepare the use of SVN. Returns the SVN (pseudo-)object.
    def init_svn
      return unless have_svn?

      pseudo_object {
        def method_missing(cmd, *args)  # :nodoc:
          options = args.last.is_a?(Hash) ? args.pop : {}
          options[:verbose] = Hen.verbose unless options.key?(:verbose)

          DSL.send(:sh, 'svn', cmd.to_s.tr('_', '-'), *args << options)
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
      }
    end

    # Extend +object+ with given +blocks+.
    def extend_object(object, *blocks, &block2)
      singleton_class = object.singleton_class

      blocks.push(block2).compact.reverse_each { |block|
        singleton_class.class_eval(&block)
      }

      object
    end

    # Create a (pseudo-)object.
    def pseudo_object(&block)
      extend_object(Object.new, block) {
        instance_methods.each { |method|
          undef_method(method) unless method =~ /\A__|\Aobject_id\z/
        }
      }
    end

    # Calls block +block+ with +args+, appending an
    # optional passed block if requested by +block+.
    def call_block(block, *args, &block2)
      args << block2 if block.arity > args.size
      block[*args]
    end

  end

end
