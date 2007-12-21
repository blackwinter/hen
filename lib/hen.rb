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
require 'hen/errors'

class Hen

  # The directory (directories?) with the hen files
  # TODO: Replace/extend with HENPATH
  HENS = File.join(File.dirname(__FILE__), 'hens')

  # Directories to search for .henrc
  RCDIRS = ['.', ENV['HOME'], File.expand_path('~')]

  find_henrc = if henrc = ENV['HENRC']
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

  # The path to the user's .henrc
  HENRC = find_henrc

  # A container for all loaded hens
  @hens = {}

  # The configuration resulting from the user's .henrc
  @config = YAML.load_file(HENRC)

  # The verbosity concerning errors and warnings
  @verbose = true

  class << self

    attr_reader :hens, :config, :verbose

    # call-seq:
    #   lay!
    #   lay! :some_hen, :some_other_hen
    #   lay! :exclude => [:some_hen, :some_other_hen]
    #
    # Loads the hens, causing them to lay their eggs^H^H^Htasks. Either all,
    # if no restrictions are specified, or the given hens, or all but those
    # given in the <tt>:exclude</tt> option.
    def lay!(*args)
      # Extract potential options hash
      options = args.last.is_a?(Hash) ? args.pop : {}

      @verbose = options[:verbose] if options.has_key?(:verbose)

      # Handle include/exclude requirements
      exclude = *options[:exclude]
      args, default = args.empty? ? [exclude || [], true] : [args, false]

      inclexcl = Hash.new(default)
      args.each { |arg|
        inclexcl[arg.to_s] = !default
      }

      # Load all available hens (as far as the
      # include/exclude conditions are met)
      load_hens { |hen|
        inclexcl[hen]
      }

      # Execute each hen definition
      hens.each { |name, hen|
        # Load any dependencies first
        load_hens(*hen.dependencies)

        begin
          hen.lay!
        rescue HenError => err
          warn "#{name}: #{err}" if verbose
        end
      }
    end

    # call-seq:
    #  add_hen(hen, overwrite = false)
    #
    # Adds +hen+ to the global container. Overwrites
    # an existing hen only if +overwrite+ is true.
    def add_hen(hen, overwrite = false)
      if overwrite
        @hens[hen.name]   = hen
      else
        @hens[hen.name] ||= hen
      end
    end

    private

    # call-seq:
    #   load_hens(*hens)
    #   load_hens(*hens) { |hen_name| ... }
    #
    # Actually loads the hen files for +hens+, or all available if none are
    # specified. If a block is given, only those hen files are loaded for
    # which the block evaluates to true.
    def load_hens(*hens, &block)
      # By default, include all
      block ||= lambda { true }

      # No hens given means get 'em all
      if hens.empty?
        # TODO: Search HENPATH for available hens
        hens = Dir[File.join(HENS, '*.rake')].map { |hen|
          File.basename(hen, '.rake')  # This is kind of awkward, but
                                       # simplifies condition checking
        }
      end

      hens.each { |hen|
        # TODO: Search HENPATH for hen
        load File.join(HENS, "#{hen}.rake") if block[hen.to_s]
      }
    end

  end

  attr_reader :name, :dependencies, :block

  # call-seq:
  #   new(args, overwrite = false) { ... }
  #
  # Creates a new Hen instance of a certain name and optional
  # dependencies; see #resolve_args for details on the +args+
  # argument. Requires a definition block; see #lay! for details.
  #
  # Adds itself to the global hen container via add_hen.
  def initialize(args, overwrite = false, &block)
    @name, @dependencies = resolve_args(args)

    unless @block = block
      raise LocalJumpError, "#{@name}: no block given" if verbose
      return
    end

    self.class.add_hen(self, overwrite)
  end

  # call-seq:
  #   hen.lay!
  #
  # Runs the definition block, exposing the DSL if requested.
  def lay!
    block.arity == 1 ? block[DSL] : block.call
  end

  # call-seq:
  #   hen.verbose
  #
  # Just an accessor to the class attribute.
  def verbose
    self.class.verbose
  end

  private

  # call-seq:
  #   resolve_args(args) => [name, dependencies]
  #
  # Splits into hen name and optional dependencies: +args+ may be a single
  # symbol (or string), or a hash with a single key pointing to a list of
  # hens this one depends upon.
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

end

# call-seq:
#   Hen(args) { ... }
#
# Just forwards to Hen.new.
def Hen(args, &block)
  Hen.new(args, &block)
end

# call-seq:
#   Hen!(args) { ... }
#
# Same as before, but overwrites any existing hen with the same name.
def Hen!(args, &block)
  Hen.new(args, true, &block)
end
