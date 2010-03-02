#--
###############################################################################
#                                                                             #
# hen -- Just a Rake helper                                                   #
#                                                                             #
# Copyright (C) 2007-2008 University of Cologne,                              #
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

require 'erb'

require 'rubygems'
require 'highline/import'

module Hen::CLI

  # Collect user's answers by key, so we don't have to ask again.
  @@values = {}

  alias_method :original_ask, :ask

  # Ask the user to enter an appropriate value for +key+. Uses
  # already stored answer if present, unless +cached+ is false.
  def ask(key, config_key = nil, cached = true, &block)
    @@values[key] = nil unless cached

    @@values[key] ||= config_key && Hen.config(config_key) ||
      original_ask("Please enter your #{key}: ", &block)
  rescue Interrupt
    abort ''
  end

  # Same as #ask, but requires a non-empty value to be entered.
  def ask!(key, config_key = nil, &block)
    msg = "#{key} is required! Please enter a non-empty value."
    max = 3

    max.times { |i|
      value = ask(key, config_key, i.zero?, &block)
      return value unless value.empty?

      puts msg
    }

    abort "You had #{max} tries -- now be gone!"
  end

  # Renders the contents of +sample+ as an ERb template,
  # storing the result in +target+. Returns the content.
  def render(sample, target)
    abort "Sample file not found: #{sample}" unless File.readable?(sample)

    if File.readable?(target)
      abort unless agree("Target file already exists: #{target}. Overwrite? ")
    end

    content = ERB.new(File.read(sample)).result(binding)

    File.open(target, 'w') { |f|
      f.puts content unless content.empty?
    }

    content
  end

end
