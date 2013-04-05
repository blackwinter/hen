#--
###############################################################################
#                                                                             #
# hen -- Just a Rake helper                                                   #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013 Jens Wille                                               #
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

require 'rake'
require 'yaml'
require 'nuggets/env/user_home'
require 'nuggets/hash/deep_merge'
require 'nuggets/proc/bind'

require 'hen/dsl'
require 'hen/version'

# The class handling the program logic. This is what you use in your Rakefile.
# See the README for more information.

class Hen

  # The directories to search for hen files. Set
  # environment variable +HENPATH+ to add more.
  HENDIRS = [File.expand_path('../hens', __FILE__)]

  ENV['HENPATH'].split(File::PATH_SEPARATOR).each { |dir|
    HENDIRS << File.expand_path(dir)
  } if ENV['HENPATH']

  HENDIRS.uniq!

  # All hens found, mapped by their name.
  HENS = Hash.new { |h, k| h[k] = [] }

  HENDIRS.each { |dir| Dir["#{dir}/*.rake"].each { |hen|
    HENS[File.basename(hen, '.rake')] << hen
  } }

  # Directories to search for <tt>.henrc</tt> files.
  RCDIRS = [ENV.user_home, '.']

  # The name of the <tt>.henrc</tt> file.
  HENRC_NAME = '.henrc'

  @hens, @verbose = {}, $VERBOSE

  class << self

    # The global container for all loaded hens.
    attr_reader :hens

    # The verbosity concerning errors and warnings.
    attr_reader :verbose

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

      yield.each { |key, value| config[key].update(value) } if block_given?

      # Handle include/exclude requirements
      excl = options[:exclude]
      args, default = args.empty? ? [excl ? [*excl] : [], true] : [args, false]

      inclexcl = Hash.new(default)
      args.each { |arg| inclexcl[arg.to_s] = !default }

      # Load all available hens (as far as the
      # include/exclude conditions are met)
      load_hens { |hen| inclexcl[hen] }

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
    # Get +hen+ by name.
    def [](hen)
      @hens[hen]
    end

    # call-seq:
    #   henrc => anArray
    #
    # The paths to the user's <tt>.henrc</tt> files.
    def henrc
      @henrc ||= find_henrc
    end

    # call-seq:
    #   default_henrc => aString
    #
    # The path to a suitable default <tt>.henrc</tt> location.
    def default_henrc
      find_henrc(false).first
    end

    # call-seq:
    #   config => aHash
    #   config(key) => anObject
    #
    # The configuration resulting from the user's <tt>.henrc</tt>. Takes
    # optional +key+ argument as "path" into the config hash, returning
    # the thusly retrieved value.
    #
    # Example:
    #   config('a/b/c')  #=> @config[:a][:b][:c]
    def config(key = nil)
      @config ||= load_config
      return @config unless key

      key.split('/').inject(@config) { |value, k| value.fetch(k.to_sym) }
    rescue IndexError, NoMethodError
    end

    private

    # call-seq:
    #   load_config => aHash
    #
    # Load the configuration from the user's <tt>.henrc</tt> files.
    def load_config
      hash = Hash.new { |h, k| h[k] = {} }

      henrc.each { |path|
        yaml = YAML.load_file(path)
        hash.deep_update(yaml) if yaml.is_a?(Hash)
      }

      hash
    end

    # call-seq:
    #   find_henrc(must_exist = true) => anArray
    #
    # Returns all readable <tt>.henrc</tt> files found in the (optional)
    # environment variable +HENRC+ and in each directory named in RCDIRS.
    # If +must_exist+ is false, no readability checks will be performed.
    def find_henrc(must_exist = true)
      RCDIRS.map { |dir|
        File.join(dir, HENRC_NAME)
      }.unshift(ENV['HENRC']).compact.map { |file|
        File.expand_path(file) if !must_exist || File.readable?(file)
      }.compact.uniq
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
        HENS[hen].each { |h| load h } if block[hen]
      }
    end

  end

  # The hen's name.
  attr_reader :name

  # The list of the hen's dependencies.
  attr_reader :dependencies

  # The hen's definition block.
  attr_reader :block

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

    @laid = false

    self.class.add_hen(self, overwrite)
  end

  # call-seq:
  #   hen.lay!
  #
  # Runs the definition block, exposing helper methods from the DSL.
  def lay!
    return if laid?

    # Call dependencies first
    dependencies.each { |hen| self.class[hen].lay!  }

    block.bind(DSL).call
  rescue => err
    warn "#{name}: #{err} (#{err.class})" if $DEBUG || verbose
    warn err.backtrace.join("\n  ") if $DEBUG
  end

  private

  # call-seq:
  #   verbose => true or false
  #
  # Delegates to Hen.verbose.
  def verbose
    self.class.verbose
  end

  # call-seq:
  #   resolve_args(args) => [name, dependencies]
  #
  # Splits into hen name and optional dependencies: +args+ may be a single
  # symbol (or string), or a hash with a single key pointing to a list of
  # hens this one depends upon.
  def resolve_args(args)
    name, dependencies = case args
      when Hash
        if args.empty?
          raise ArgumentError, 'No hen name given'
        elsif args.size > 1
          raise ArgumentError, "Too many hen names: #{args.keys.join(' ')}"
        end

        [args.keys.first, [*args.values.first]]
      else
        [args, []]
    end

    [name.to_sym, dependencies.map { |dependency| dependency.to_sym }]
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
# Delegates to Hen.new.
def Hen(args, &block)
  Hen.new(args, &block)
end

# call-seq:
#   Hen!(args) { ... }
#
# Delegates to Hen.new, but overwrites
# any existing hen with the same name.
def Hen!(args, &block)
  Hen.new(args, true, &block)
end
