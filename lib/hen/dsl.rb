#--
###############################################################################
#                                                                             #
# A component of hen, the Rake helper.                                        #
#                                                                             #
# Copyright (C) 2007 University of Cologne,                                   #
#                    Albertus-Magnus-Platz,                                   #
#                    50932 Cologne, Germany                                   #
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

    # call-seq:
    #   hen.requires(*tasks)
    #
    # Specify a list of +tasks+ the hen requires to be present in
    # actual the Rakefile. In case one of those is not available,
    # a HenError::TaskRequired error is raised.
    def requires(*tasks)
      tasks.each { |task|
        raise HenError::TaskRequired.new(task) \
          unless Rake::Task.task_defined?(task)
      }
    end

    # call-seq:
    #   hen.call(task)
    #
    # Short-cut to call Rake task +task+.
    def call(task)
      Rake::Task[task].invoke.first.call
    end

    # call-seq:
    #   hen.config
    #
    # The Hen configuration.
    def config
      Hen.config
    end

    # call-seq:
    #   hen[key]
    #
    # Short-cut to the config.
    def [](key)
      config[key]
    end

  end

end
