#--
###############################################################################
#                                                                             #
# hen -- Just a Rake helper                                                   #
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
require 'etc'
require 'erb'
require 'highline/import'

class Hen

  # Some helper methods used by the Hen executable. Also available
  # for use in custom project skeletons.

  module CLI

    @answers = {}

    class << self

      # Collect user's answers by key, so we don't have to ask again.
      attr_reader :answers

    end

    # Renders the contents of +sample+ as an ERb template,
    # storing the result in +target+. Returns the content.
    def render(sample, target)
      abort "Sample file not found: #{sample}" unless File.readable?(sample)

      if File.readable?(target)
        abort unless agree("Target file already exists: #{target}. Overwrite? ")
        FileUtils.cp(target, "#{target}.bak-#{Time.now.to_i}")
      end

      content = ERB.new(File.read(sample)).result(binding)

      File.open(target, 'w') { |f| f.puts content unless content.empty? }

      content
    end

    # The project name. (Required)
    #
    # Quoting the {Ruby Packaging Standard}[http://chneukirchen.github.com/rps/]:
    #
    # Project names SHOULD only contain underscores as separators
    # in their names.
    #
    # If a project is an enhancement, plugin, extension, etc. for
    # some other project it SHOULD contain a dash in the name
    # between the original name and the project's name.
    def progname(default = nil)
      ask!("Project's name", default)
    end

    # The project's namespace. (Required)
    #
    # Namespaces SHOULD match the project name in SnakeCase.
    def classname(default = default_classname)
      ask!("Module's/Class's name", default)
    end

    # The author's full name. (Required)
    def fullname(default = default_fullname)
      ask!('Full name', default)
    end

    # The author's e-mail address. (Optional, but highly recommended)
    def emailaddress(default = default_emailaddress)
      ask('E-mail address', default)
    end

    # A short one-line summary of the project's description. (Required)
    def progdesc(default = nil)
      ask!("Program's description summary", default)
    end

    private

    # Determine a suitable default namespace from the project name.
    def default_classname
      pname = progname
      pname.gsub(/(?:\A|_)(.)/) { $1.upcase } if pname && !pname.empty?
    end

    # Determine a default name from the global config or, if available,
    # from the {GECOS field}[http://en.wikipedia.org/wiki/Gecos_field]
    # in the <tt>/etc/passwd</tt> file.
    def default_fullname
      author = Hen.config('gem/author')
      return author if author && !author.empty?

      pwent = Etc.getpwuid(Process.euid)
      gecos = pwent.gecos if pwent
      gecos[/[^,]*/] if gecos && !gecos.empty?
    end

    # Determine a default e-mail address from the global config.
    def default_emailaddress
      email = Hen.config('gem/email')
      return email if email && !email.empty?
    end

    alias_method :_hen_original_ask, :ask

    # Ask the user to enter an appropriate value for +key+. Uses
    # already stored answer if present, unless +cached+ is false.
    def ask(key, default = nil, cached = true)
      CLI.answers[key] = nil unless cached

      CLI.answers[key] ||= _hen_original_ask("Please enter your #{key}: ") { |q|
        q.default = default if default
      }
    rescue Interrupt
      abort ''
    end

    # Same as #ask, but requires a non-empty value to be entered.
    def ask!(key, default = nil, max = 3)
      msg = "#{key} is required! Please enter a non-empty value."

      max.times { |i|
        value = ask(key, default, i.zero?)
        return value unless value.empty?

        puts msg
      }

      warn "You had #{max} tries now -- giving up..."
      ''  # default value
    end

  end

end
