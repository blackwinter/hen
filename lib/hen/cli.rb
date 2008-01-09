#--
###############################################################################
#                                                                             #
# hen -- Just a Rake helper                                                   #
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

require 'erb'

require 'rubygems'
require 'highline/import'

module Hen::CLI

  # Collect user's answers by key, so we don't have to ask again.
  @@values = {}

  alias_method :original_ask, :ask
  def ask(key)
    @@values[key] ||= original_ask("Please enter your #{key}: ")
  end

  def render(template, target)
    abort "Sample file not found: #{template}" unless File.readable?(template)

    if File.readable?(target)
      abort unless agree("Target file already exists: #{target}. Overwrite? ")
    end

    File.open(target, 'w') { |f|
      f.puts ERB.new(File.read(template)).result(binding)
    }
  end

end
