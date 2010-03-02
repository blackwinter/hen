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

require 'yaml'
require 'forwardable'

require 'rubygems'
require 'rake'
require 'nuggets/env/user_home'
require 'nuggets/proc/bind'

require 'hen/dsl'
require 'hen/version'

class Hen

  # The directories which contain the hen files
  HENDIRS = [File.join(File.dirname(__FILE__), 'hens')] +
            (ENV['HENPATH'] || '').split(File::PATH_SEPARATOR)

  # All hens found, mapped by their name
  HENS = Dir[*HENDIRS.map { |d| "#{d}/*.rake" }].uniq.inject(
    Hash.new { |h, k| h[k] = [] }
  ) { |hash, hen|
    hash[File.basename(hen, '.rake')] << hen; hash
  }

  # Directories to search for .henrc
  RCDIRS = ['.', ENV.user_home]

  # A container for all loaded hens
  @hens = {}

  # The verbosity concerning errors and warnings
  @verbose = true

  class << self

    attr_reader :hens, :verbose

    # call-seq:
    #   lay!
    #   lay!(:some_hen, :some_other_hen)
    #   lay!(:exclude => [:some_hen, :some_other_hen])
    #
    # Loads the hens, causing them to lay their eggs^H^H^Htasks. Either all,
    # if no restrictions are specified, or the given hens, or all but those
    # given in the <tt>:exclude</tt> option.
    def lay!(*args)
      # Extract potential options hash
      options = args.last.is_a?(Hash) ? args.pop : {}

      @verbose = options[:verbose] if options.has_key?(:verbose)

      if block_given?
        yield.each { |key, value| (config[key] ||= {}).update(value) }
      end

      # Handle include/exclude requirements
      excl = options[:exclude]
      args, default = args.empty? ? [excl ? [*excl] : [], true] : [args, false]

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
        # Load any dependencies, in case they're not included yet
        begin
          load_hens(*hen.dependencies)
        rescue LoadError => err
          warn "#{name}: Required dependency missing: " <<
               File.basename(err.to_s, '.rake') if verbose
          next
        end

        hen.lay!
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

    # call-seq:
    #   Hen[hen] => aHen
    #
    # Get hen by name.
    def [](hen)
      @hens[hen]
    end

    # call-seq:
    #   henrc => aString
    #
    # The path to the user's .henrc
    def henrc(location_only = false)
      @henrc ||= find_henrc(location_only)
    end

    # call-seq:
    #   config => aHash
    #   config(key) => aValue
    #
    # The configuration resulting from the user's .henrc. Takes optional
    # +key+ argument as "path" into the config hash, returning the thusly
    # retrieved value.
    #
    # Example:
    #   config('a/b/c')  #=> @config[:a][:b][:c]
    def config(key = nil)
      @config ||= YAML.load_file(henrc)
      return @config unless key

      key.split('/').inject(@config) { |value, k|
        value.fetch(k.to_sym)
      }
    rescue IndexError, NoMethodError
    end

    private

    # call-seq:
    #   find_henrc(location_only = false) => aString
    #
    # Search for a readable .henrc, or, if +location_only+ is true, just return
    # a suitable default location.
    def find_henrc(location_only = false)
      return ENV['HENRC'] || File.join(RCDIRS.last, '.henrc') if location_only

      if    henrc = ENV['HENRC']
        abort "The specified .henrc file could not be found: #{henrc}" \
          unless File.readable?(henrc)
      elsif henrc = RCDIRS.find { |dir|
        h = File.join(dir, '.henrc')
        break h if File.readable?(h)
      }
      else
        abort "No .henrc file could be found! Please " <<
              "create one first by running 'hen config'."
      end

      henrc
    end

    # call-seq:
    #   load_hens(*hens)
    #   load_hens(*hens) { |hen_name| ... }
    #
    # Actually loads the hen files for +hens+, or all available if none are
    # specified. If a block is given, only those hen files are loaded for
    # which the block evaluates to true.
    def load_hens(*hens, &block)
      # By default, include all
      block ||= lambda { |_| true }

      (hens.empty? ? HENS.keys : hens).each { |hen|
        hen = hen.to_s
        next unless block[hen]

        HENS[hen].each { |h| load h }
      }
    end

  end

  extend Forwardable

  # Forward to the class
  def_delegators self, :verbose

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
  # Runs the definition block, exposing helper methods from the DSL.
  def lay!
    return if laid?

    # Call dependencies first
    dependencies.each { |hen|
      self.class[hen].lay!
    }

    block.bind(DSL).call
  rescue => err
    warn "#{name}: #{err} (#{err.class})" if verbose
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
        raise ArgumentError, 'No hen name given' \
          if args.size < 1

        [args.keys.first, [*args.values.first]]
      else
        [args, []]
    end

    [name.to_sym, dependencies.map { |d| d.to_sym }]
  end

  # call-seq:
  #   laid? => true or false
  #
  # Keeps track of whether the block has already been executed.
  def laid?
    return @laid if @laid

    @laid = true
    false
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
# Same as above, but overwrites any existing hen with the same name.
def Hen!(args, &block)
  Hen.new(args, true, &block)
end
