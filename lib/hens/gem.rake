Hen :gem => :rdoc do
  # Dependencies:
  # * rdoc -- Uses RDOC_OPTIONS and 'doc:publish' task

  gem_options = config[:gem].merge(
    :files => FileList[
      'lib/**/*.rb',
      'bin/*'
    ].to_a,
    :default_extra_files => FileList[
      '[A-Z]*',
      'example/**/*',
      'ext/**/*',
      'spec/**/*', '.rspec',
      'test/**/*', '.autotest'
    ].to_a,
    :extensions => FileList[
      'ext/**/extconf.rb'
    ].to_a,
    :require_path => 'lib'
  )

  gem_klass = begin
    raise LoadError if gem_options.delete(:legacy)

    require 'rubygems/package_task'
    Gem::PackageTask
  rescue LoadError
    require 'rake/gempackagetask'
    Rake::GemPackageTask
  end

  rf_config = config[:rubyforge]

  if Object.const_defined?(:RDOC_OPTIONS)
    rdoc_files = RDOC_OPTIONS[:rdoc_files]
    gem_options[:has_rdoc] = !rdoc_files.empty? if Gem::VERSION < '1.7'

    gem_options[:rdoc_options] ||= RDOC_OPTIONS[:options]
  end

  gem_spec = Gem::Specification.new { |spec|

    ### name

    gem_name = gem_options[:name] ||= project_name(rf_config)

    abort 'Gem name missing' unless gem_name

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

    ### rubyforge project, homepage

    gem_options[:rubyforge_project] ||= rf_config[:project]

    if rf_project = gem_options[:rubyforge_project] and !rf_project.empty?
      rf_rdoc_dir = RDOC_OPTIONS[:rf_rdoc_dir] if Object.const_defined?(:RDOC_OPTIONS)
      gem_options[:homepage] ||= "#{rf_project}.rubyforge.org/#{rf_rdoc_dir}"
    end

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

    unless gem_options[:executables].empty?
      gem_options[:bindir] ||= File.dirname(gem_options[:executables].first)
      gem_options[:executables].map! { |executable| File.basename(executable) }
    end

    ### dependencies

    (gem_options.delete(:dependencies) || []).each { |dependency|
      spec.add_dependency(*dependency)
    }

    (gem_options.delete(:development_dependencies) || []).each { |dependency|
      spec.add_development_dependency(*dependency)
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

  desc 'Display the gem specification'
  task 'gem:spec' do
    puts gem_spec.to_ruby
  end

  desc "Update (or create) the project's gemspec file"
  task 'gem:spec:update' do
    file = "#{gem_spec.name}.gemspec"
    action = File.exists?(file) ? 'Updated' : 'Created'

    File.open(file, 'w') { |f| f.puts gem_spec.to_ruby }

    puts "#{action} #{file}"
  end

  pkg_task = gem_klass.new(gem_spec) { |pkg|
    pkg.need_tar_gz = true
    pkg.need_zip    = true

    if defined?(ZIP_COMMANDS)
      require 'nuggets/file/which'
      pkg.zip_command = File.which_command(ZIP_COMMANDS) || ZIP_COMMANDS.first
    end
  }

  release_desc = "Release #{gem_spec.name} version #{gem_spec.version}"
  tag_desc     = "Tag the #{gem_spec.name} release version #{gem_spec.version}"

  rubygems do |rg_pool|

    gem_path = File.join(pkg_task.package_dir, gem_spec.file_name)

    desc "Create the gem and install it"
    task 'gem:install' => :gem do
      rg_pool.call.install(gem_path)
    end

    desc 'Create the gem and upload it to RubyGems.org'
    task 'gem:push' => :gem do
      rg_pool.call.push(gem_path)
    end

    desc release_desc; release_desc = nil
    task :release => 'gem:push'

  end

  rubyforge do |rf_config, rf_pool|

    desc 'Package and upload the release to RubyForge'
    task 'release:rubyforge' => [:package, 'doc:publish:rubyforge'] do
      files = Dir[File.join(pkg_task.package_dir, "#{pkg_task.package_name}.*")]
      abort 'Nothing to release!' if files.empty?

      # shorten to (at most) three digits
      version = gem_spec.version.to_s.split(/([.])/)[0..4].join

      rf = rf_pool.call

      # TODO: Add release notes and changes.
      #uc = rf.userconfig
      #uc['release_notes']   = description if description
      #uc['release_changes'] = changes if changes
      #uc['preformatted']    = true

      rf.add_release(rf_config[:project], gem_spec.name, version, *files)
    end

    desc release_desc
    task :release => 'release:rubyforge'

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

  %w[doc:publish release:tag].each { |t| task :release => t if have_task?(t) }

end
