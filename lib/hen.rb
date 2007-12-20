#--
###############################################################################
#                                                                             #
# hen -- Just a Rake helper                                                   #
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

require 'rake'
require 'yaml'

require 'hen/dsl'

module Hen

  extend self

  HENS   = File.join(File.dirname(__FILE__), 'hens')
  RCDIRS = ['.', ENV['HOME'], File.expand_path('~')]

  HENRC = if henrc = ENV['HENRC']
    if File.readable?(henrc)
      henrc
    else
      abort "The specified .henrc file could not be found: #{henrc}"
    end
  else
    RCDIRS.find { |path|
      henrc = File.join(path, '.henrc')
      break henrc if File.readable?(henrc)
    } or abort "No .henrc file could be found! " <<
               "Please create one first ('hen config')."
  end

  @@hens   = Hash.new { |h, k| h[k] = true; false }
  @@config = YAML.load_file(HENRC)

  def create(args, &block)
    name, dependencies = resolve_args(args)

    raise LocalJumpError, "#{name}: no block given" unless block

    return if @@hens[name]

    dependencies.each { |hen|
      load File.join(HENS, "#{hen}.rake")
    }

    begin
      block[DSL.new]
    rescue Error => err
      warn err.to_s
    end
  end

  def lay
    Dir[File.join(Hen::HENS, '*.rake')].each { |hen|
      load hen
    }
  end

  def config
    @@config
  end

  private

  def resolve_args(args)
    name, dependencies = case args
      when Hash
        raise ArgumentError, "Too many hen names: #{args.keys.join(' ')}" \
          if args.size > 1
        raise ArgumentError, "No hen name given" \
          if args.size < 1

        [args.keys.first, [*args.values.first]]
      else
        [args, []]
    end

    [name.to_sym, dependencies.map { |d| d.to_sym }]
  end

  class Error < StandardError
  end

  class TaskRequired < Error

    def initialize(task)
      @task = task
    end

    def to_s
      "Required task missing: #{@task}"
    end

  end

end

def Hen(args, &block)
  Hen.create(args, &block)
end
