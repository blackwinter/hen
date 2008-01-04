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

    # Call Rake task +task+. Raises HenError::TaskRequired if task is not defined.
    def call_task(task)
      raise HenError::TaskRequired.new(task) unless Rake::Task.task_defined?(task)
      Rake::Task[task].invoke.first.call
    end

    # The Hen configuration.
    def config
      Hen.config
    end

    # Define task +t+, but overwrite any existing task of that name!
    # (Rake usually just adds them up)
    def task!(t, &block)
      Rake.application.instance_variable_get(:@tasks).delete(t.to_s)
      task(t, &block)
    end

  end

end
