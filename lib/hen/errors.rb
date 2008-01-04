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

  # Base class for Hen errors.
  class HenError < StandardError

    # Raised if a required configuration is missing.
    class ConfigRequired < HenError

      # call-seq:
      #   new(key)
      #
      def initialize(key)
        @key = key
      end

      # call-seq:
      #   to_s
      #
      def to_s
        "Required configuration missing for #{@key}"
      end

    end

  end

end
