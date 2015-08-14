Hen gem: :rdoc do
  # Dependencies:
  # * rdoc -- Uses RDOC_OPTIONS and 'doc:publish' task

  gem_options = {
    files: FileList[
      'lib/**/*.rb',
      'bin/*'
    ].to_a,
    default_extra_files: FileList[
      '[A-Z]*',
      'example/**/*',
      'ext/**/*',
      'spec/**/*', '.rspec',
      'test/**/*', '.autotest'
    ].to_a,
    extensions: FileList[
      'ext/**/extconf.rb'
    ].to_a,
    require_path: 'lib'
  }.update(config[:gem])

  require 'rubygems/package_task'

  if Object.const_defined?(:RDOC_OPTIONS)
    rdoc_files = RDOC_OPTIONS[:rdoc_files]
    gem_options[:rdoc_options] ||= RDOC_OPTIONS[:options]
  end

  extension_options = gem_options.delete(:extension) || {}

  meta_gems, meta_gem_specs = Array(gem_options.delete(:meta)), []

  abort 'Gem name missing' unless gem_name = gem_options[:name]

  gem_spec = Gem::Specification.new { |spec|

    ### version

    abort 'Gem version missing' unless gem_options[:version]

    svn { |svn|
      gem_options[:version] << '.' << svn.version
    } if gem_options.delete(:append_svnversion)

    ### author(s)

    authors = gem_options[:authors] ||= []
    authors.concat(Array(gem_options.delete(:author))).uniq!

    warn 'Gem author(s) missing' if authors.empty?

    ### description

    gem_options[:description] ||= gem_options[:summary]

    ### homepage

    if homepage = gem_options[:homepage]
      homepage = "github.com/#{homepage}/#{gem_name}" if homepage.is_a?(Symbol)
      homepage.insert(0, 'http://') unless homepage.empty? || homepage =~ %r{://}
      gem_options[:homepage] = homepage
    end

    ### extra_rdoc_files, files, extensions, executables, bindir

    gem_options[:files]            ||= []
    gem_options[:extensions]       ||= []
    gem_options[:extra_rdoc_files] ||= rdoc_files - gem_options[:files] if rdoc_files

    [:extra_files, :default_extra_files].each { |files|
      gem_options[:files].concat(gem_options.delete(files) || [])
    }

    if exclude_files = gem_options.delete(:exclude_files)
      gem_options[:files] -= exclude_files
    end

    gem_options[:executables] ||= gem_options[:files].grep(%r{\Abin/})

    mangle_files!(*gem_options.values_at(
      :extra_rdoc_files, :files, :executables, :extensions
    ))

    unless (local_files = Array(gem_options.delete(:local_files))).empty?
      gem_options[:files].concat(local_files)

      task :pkg     => local_files
      task :compile => local_files

      CLOBBER.include(*local_files)
    end

    unless gem_options[:executables].empty?
      gem_options[:bindir] ||= File.dirname(gem_options[:executables].first)
      gem_options[:executables].map! { |executable| File.basename(executable) }
    end

    ## post_install_message

    post_install_message = gem_options[:post_install_message]

    gem_options[:post_install_message] = case post_install_message
      when nil, true
        log = ENV['HEN_CHANGELOG'] || gem_options[:files].grep(
          %r{\A(?:change(?:s|log)|history)[^/]*\z}i).first || 'ChangeLog'

        if File.readable?(log)
          msg, ver = [], gem_options[:version].sub(/\.?[^\d.].*/, '')

          heading, found = /\A== (#{Regexp.escape(ver)}\D.*)/o, false

          File.foreach(log) { |line|
            line.chomp!

            case line
              when heading then msg << "#{gem_name}-#{found = $1}:"
              when /\A== / then break if found
              else msg << line if found
            end
          }

          "\n#{msg.join("\n").strip}\n\n" unless msg.empty?
        elsif post_install_message
          warn "File not found: #{log}. Skipping post_install_message." if Hen.verbose
        end
      when false
      else post_install_message
    end

    ### dependencies

    dependencies             = Array(gem_options.delete(:dependencies))
    development_dependencies = Array(gem_options.delete(:development_dependencies))

    default_dependencies = [['hen', *Hen::Version.pessimistic_requirement], 'rake']
    default_dependencies << 'rake-compiler' unless gem_options[:extensions].empty?

    unless (test_files = gem_options[:files].grep(/\A(?:test|spec)s?\//)).empty?
      test_dependency = case test_files.first.split(File::SEPARATOR).first
        when 'test' then 'test-unit'
        when 'spec' then 'rspec'
        else if helper_file = test_files.grep(/_helper\.rb\z/).first
          File.read(helper_file)[/^\s*require\s+(['"])(.*?)\1/, 2]
        end
      end

      default_dependencies << test_dependency.tr('/', '-') if test_dependency
    end

    exclude_default_dependencies = [gem_name]

    dependencies.each { |name, *requirements|
      exclude_default_dependencies << name
      spec.add_runtime_dependency(name, *requirements)
    }

    development_dependencies.each { |name, *requirements|
      exclude_default_dependencies << name
      spec.add_development_dependency(name, *requirements)
    }

    default_dependencies.each { |name, *requirements|
      next if exclude_default_dependencies.include?(name)
      spec.add_development_dependency(name, *requirements)
    }

    spec.dependencies.each { |dependency|
      warn "WARNING: Prerelease dependency: #{dependency}" if dependency.prerelease?
    }

    ### => set options!

    set_options(spec, gem_options, 'Gem')

  }

  desc 'Check the gem dependencies'
  task 'gem:dependencies' do
    errors, $stdout.sync = [], true

    gem_spec.dependencies.each { |dependency|
      print 'Checking for %s dependency %s (%s)... ' % [
        dependency.type, dependency.name, dependency.requirement
      ]

      sleep(0.2 + rand / 2)  # ;)

      begin
        spec = dependency.to_spec
        spec.activate

        puts "found (#{spec.version})"
      rescue Exception => err
        errors << err

        puts "not found (#{err.class})"
      end
    }

    errors.each { |err| warn "\n#{err}" } if $VERBOSE || Rake.verbose

    exit 1 unless errors.empty?
  end

  desc "List gem dependencies' current versions"
  task 'gem:dependencies:current' do
    gem_spec.dependencies.each { |dependency|
      req = dependency.requirement.as_list.map(&:to_s)

      print '%s (%s: %s): ' % [
        dependency.name, dependency.type, req.join(', ')
      ]

      begin
        ver = dependency.to_spec.version
        rec = ver.approximate_recommendation

        puts "#{ver}#{" (#{rec})" unless req.include?(rec)}"
      rescue Exception => err
        puts "#{err.class} (#{err})"
      end
    }
  end

  desc 'Display the gem specification'
  task 'gem:spec' do
    puts gem_spec.to_ruby
  end

  desc "Update (or create) the project's gemspec file"
  task 'gem:spec:update' do
    write_gemspec(gem_spec)
  end

  meta_gems.each { |meta_gem_options|

    noauto = meta_gem_options.delete(:noauto)

    meta_gem_specs << meta_gem_spec = Gem::Specification.new { |spec|

      ### inherit from original spec

      %w[
        name version summary description
        authors email license homepage
      ].each { |key|
        meta_gem_options[key = key.to_sym] ||= gem_options[key]
      }

      ### name + summary suffixes

      if suffix = meta_gem_options.delete(:suffix)
        meta_gem_options[:name] += "-#{suffix}"
      end

      summary_suffix = meta_gem_options.delete(:summary_suffix) || 'virtual package'
      meta_gem_options[:summary] += " (#{summary_suffix})" unless summary_suffix.empty?

      ### dependencies

      [
        [gem_options[:name], gem_options[:version]],
        *Array(meta_gem_options.delete(:dependencies))
      ].each { |dependency|
        spec.add_dependency(*dependency)
      }

      ### => set options!

      set_options(spec, meta_gem_options, 'Gem')

    }

    meta_prefix = "gem:meta:#{meta_gem_name = meta_gem_spec.name}"
    meta_class  = meta_gem_spec.singleton_class

    meta_class.send(:define_method, :auto?)    { !noauto }
    meta_class.send(:define_method, :taskname) { meta_prefix }

    desc "Display the #{meta_gem_name} gem specification"
    task "#{meta_prefix}:spec" do
      puts meta_gem_spec.to_ruby
    end

    desc "Update (or create) the project's #{meta_gem_name} gemspec file"
    task "#{meta_prefix}:spec:update" do
      write_gemspec(meta_gem_spec)
    end

    task 'gem:spec:update' => "#{meta_prefix}:spec:update" unless noauto

  }

  pkg_task = Gem::PackageTask.new(gem_spec) { |pkg|
    pkg.need_tar_gz = true
    pkg.need_zip    = true

    if defined?(ZIP_COMMANDS)
      pkg.zip_command = File.which_command(ZIP_COMMANDS) || ZIP_COMMANDS.first
    end
  }

  meta_gem_specs.each { |meta_gem_spec|

    meta_pkg_task = Gem::PackageTask.new(meta_gem_spec)

    taskname = meta_gem_spec.taskname

    gem_file = File.basename(meta_gem_spec.cache_file)
    gem_path = File.join(package_dir = meta_pkg_task.package_dir, gem_file)

    desc "Build the meta gem file #{gem_file}"
    task taskname => gem_path

    Gem.configuration.verbose = trace = Rake.application.options.trace

    file gem_path => package_dir do
      when_writing "Creating #{meta_gem_spec.file_name}" do
        Gem::Builder.new(meta_gem_spec).build
        verbose(trace) { mv gem_file, package_dir }
      end
    end

    %w[package gem].each { |t| task t => taskname } if meta_gem_spec.auto?

  }

  begin
    require 'rake/extensiontask' unless gem_spec.extensions.empty?
  rescue LoadError
    missing_lib 'rake/extensiontask'
  end

  if Rake.const_defined?(:ExtensionTask)
    # gem_name       | ext_name  | extension name
    # ---------------------------------------
    # unicode        | unicode   | unicode_native
    # libcdb-ruby    | libcdb    | libcdb_ruby
    # ruby-filemagic | filemagic | ruby_filemagic
    # rb-gsl         | gsl       | gsl_native

    gem_name_parts = gem_name.split('-')
    gem_name_parts.shift if gem_name_parts.first == 'rb'
    gem_name_parts << 'native' if gem_name_parts.size == 1

    extension_options[:name] ||= gem_name_parts.join('_')

    ext_name = extension_options.delete(:ext_name) {
      gem_name_parts.find { |part| part != 'ruby' } }

    extension_options[:lib_dir] ||= File.join(['lib', ext_name, ENV['FAT_DIR']].compact)
    extension_options[:ext_dir] ||= File.join(['ext', ext_name].compact)

    cross_config_options = nil

    extension_options.delete_if { |key, val|
      key =~ /\Awith_cross_(\w+)\z/ or next false
      dir = ENV[key.to_s.upcase] or next true

      cross_config_options ||= []

      case res = val[dir]
        when Array
          inc, lib = res; lib = inc if res.size == 1

          cross_config_options << "--with-#{$1}-include=#{inc}" if inc
          cross_config_options << "--with-#{$1}-lib=#{lib}" if lib
        when String
          cross_config_options << "--with-#{$1}-dir=#{res}"
      end
    }

    if cross_config_options
      extension_options[:cross_config_options] ||= []
      extension_options[:cross_config_options].concat(cross_config_options)
    end

    unless extension_options.key?(:cross_compile)
      extension_options[:cross_compile] =
        extension_options[:cross_config_options].is_a?(Array) ?
          !extension_options[:cross_config_options].empty? : true
    end

    if extension_options[:cross_compile]
      extension_options[:cross_platform] ||= %w[x86-mswin32-60 x86-mingw32]

      if ruby_versions = extension_options.delete(:cross_ruby_versions)
        ENV['RUBY_CC_VERSION'] ||= Array(ruby_versions).join(':')
      end

      if File.exist?(rc_config = File.expand_path('~/.rake-compiler/config.yml'))
        ENV['RUBY_CC_VERSION'] ||= SafeYAML.load_file(rc_config).keys.
                                     map { |k| k.split('-').last }.uniq.join(':')
      end

      desc 'Build native gems'
      task 'gem:native' => %w[cross compile rake:native gem]
    end

    extension_task = Rake::ExtensionTask.new(nil, gem_spec) { |ext|
      ext.cross_compiling(&extension_options.delete(:cross_compiling))

      set_options(ext, extension_options, 'Extension')
    }

    %w[spec test].each { |t| task t => :compile }
  else
    skipping 'Extension'
  end

  release_desc = "Release #{gem_name} version #{gem_spec.version}"
  tag_desc     = "Tag the #{gem_name} release version #{gem_spec.version}"

  rubygems do |rg_pool|

    gem_base = pkg_task.package_dir
    gem_path = File.join(gem_base, gem_spec.file_name)

    desc 'Install the gem dependencies'
    task 'gem:dependencies:install' do
      gem_spec.dependencies.each { |dependency|
        rg_pool.call.install(dependency.name, '-v', dependency.requirement.to_s)
      }
    end

    desc 'Create the gem and install it'
    task 'gem:install' => :gem do
      rg_pool.call.install(gem_path)
    end

    desc 'Create the gem and upload it to RubyGems.org'
    task 'gem:push' => :gem do
      rg_pool.call.push(gem_path)
    end

    meta_gem_specs.each { |meta_gem_spec|
      taskname = meta_gem_spec.taskname

      desc "Create the meta gem #{meta_gem_spec.name} and upload it to RubyGems.org"
      task "#{taskname}:push" => taskname do
        rg_pool.call.push(File.join(gem_base, meta_gem_spec.file_name))
      end

      task 'gem:push:meta' => "#{taskname}:push" if meta_gem_spec.auto?
    }

    if have_task?('gem:push:meta')
      desc 'Create the meta gems and upload them to RubyGems.org'
      task 'gem:push:meta'

      task 'gem:push' => 'gem:push:meta'
    end

    if have_task?('gem:native')
      platforms = Array(extension_task.cross_platform).join(',')
      gems_glob = gem_path.sub(/(?=\.gem\z)/, "-{#{platforms}}")

      desc 'Create the native gems and upload them to RubyGems.org'
      task 'gem:push:native' => 'gem:native' do
        rg = rg_pool.call
        Dir[gems_glob].each { |native_gem| rg.push(native_gem) }
      end

      task 'gem:push' => 'gem:push:native'
    end

    desc release_desc; release_desc = nil
    task release: 'gem:push'

  end

  git do |git|

    desc "#{tag_desc} (Git)"
    task! 'release:tag' do
      git.tag '-f', "v#{gem_spec.version}"
    end

  end

  svn do |svn|

    desc "#{tag_desc} (SVN)"
    task! 'release:tag' do
      svn.cp '-m', "v#{gem_spec.version}", '^/trunk', "^/tags/#{gem_spec.version}"
    end

  end

  %w[doc:publish release:tag].each { |t| task release: t if have_task?(t) }

  def write_gemspec(gem_spec)
    file = "#{gem_spec.name}.gemspec"
    action = File.exists?(file) ? 'Updated' : 'Created'

    File.write(file, gem_spec.to_ruby)

    puts "#{action} #{file}"
  end

end
