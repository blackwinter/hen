#--
###############################################################################
#                                                                             #
# hen -- Just a Rake helper                                                   #
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

# TODO: Implement 'list' command -- List available hens with their tasks (?)

require 'fileutils'
require 'nuggets/argv/option'
require 'nuggets/enumerable/minmax'

require 'hen/cli'

class Hen

  module Commands

    extend self

    extend CLI

    COMMANDS = {
      'config'  => 'Create a fresh .henrc file',
      'create'  => [
        'Create a new project directory tree',
        'Arguments: path [sample-skeleton]',
        'Options: -g, --git [[remote=]url]'
      ],
      'help'    => 'Print this help and exit',
     #'list'    => 'List available hens with their tasks',
      'version' => 'Display version number'
    }

    USAGE = <<-EOT
Usage: #{$0} {#{COMMANDS.keys.sort.join('|')}} [arguments] [options]
       #{$0} [-h|--help] [--version]
    EOT

    SKELETON = File.expand_path('../../../example', __FILE__)

    def [](arg)
      arg = arg.sub(/\A-+/, '')
      arg !~ /\W/ && public_method_defined?(arg) ? send(arg) : method_missing(arg)
    end

    def usage
      abort USAGE
    end

    def help
      puts USAGE
      puts
      puts 'Commands:'

      max = COMMANDS.keys.max(:length)

      COMMANDS.sort.each { |cmd, desc|
        puts "  %-#{max}s - %s" % [cmd, (desc = [*desc]).shift]
        desc.each { |extra| puts "  %#{max}s   + %s" % [' ', extra] }
      }
    end

    alias_method :h, :help

    def list
      # How to achieve? Has to list *all* hens and tasks made available therein,
      # *regardless* of any missing prerequisites (preferably indicating whether
      # a particular hen/task is currently available).
      abort 'Sorry, not yet available...'
    end

    def version
      puts "hen v#{VERSION}"
    end

    def config
      render(File.join(SKELETON, '_henrc'), henrc = Hen.default_henrc)

      puts
      puts "Your .henrc has been created: #{henrc}. Now adjust it to your needs."
    end

    def create
      abort 'Path argument missing!' unless path = ARGV.shift

      skel = ARGV.first !~ /^-/ && ARGV.shift || File.join(SKELETON, 'project')
      abort "Project skeleton not found: #{skel}" unless File.directory?(skel)

      create_path(path = File.expand_path(path), created = [])
      create_skel(path, skel = File.expand_path(skel), created, replace = {})

      puts
      puts "Your new project directory has been created: #{path}. Have fun!"

      replace.each { |target, details|
        puts ["\n#{target}:", *details].join("\n  ") unless details.empty?
      }.clear
    end

    private

    def method_missing(method, *)
      abort "Illegal command: #{method}\n#{USAGE}"
    end

    def create_path(path, created)
      if File.directory?(path)
        abort "Target directory already exists: #{path}. Won't touch."
      else
        Dir.mkdir(path)
        created << path
      end
    end

    def create_skel(path, skel, created, replace)
      progname(File.basename(path))  # pre-fill

      git = create_git(path, created)

      Dir.chdir(skel) {
        Dir['**/*'].each { |sample|
          next unless target = mangle_target(path, sample, git)

          created << target

          File.directory?(sample) ? FileUtils.mkdir_p(target) :
            replace[target] = render(sample, target).scan(/### .+ ###/)
        }
      }

      created.clear
    ensure
      created.reverse_each { |item|
        if File.exist?(item)
          begin
            (File.directory?(item) ? Dir : File).unlink(item)
          rescue Errno::ENOTEMPTY
            File.basename(item) == '.git' ? FileUtils.rm_rf(item) : raise
          end
        end
      }.clear
    end

    def create_git(path, created)
      ARGV.option!(:g, :git) { |remote|
        Dir.chdir(path) {
          if system('git', 'init')
            created << File.join(path, '.git')

            if remote.nil? && githubuser
              remote = "git@github.com:#{githubuser}/#{progname}"
            end

            unless remote.nil? || remote.empty?
              url, label = remote.split('=', 2).reverse
              system('git', 'remote', 'add', label ||= 'origin', url)

              system('git', 'config', 'branch.master.remote', label)
              system('git', 'config', 'branch.master.merge', 'refs/heads/master')
            end
          end
        }

        true
      }
    end

    def mangle_target(path, sample, git)
      target = sample.gsub(/__(.+?)__/) { send($1) }

      dir, name = File.split(target)
      name.sub!(/\A_/, '.')

      File.join(path, dir, name) if git || !name.start_with?('.git')
    end

  end

end
