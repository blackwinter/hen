Hen :gem => :rdoc do
  # Dependencies:
  # * rdoc -- Uses RDOC_OPTIONS and 'publish_docs' task

  require 'rake/gempackagetask'

  gem_options = config[:gem]
  rf_config   = config[:rubyforge]

  if Object.const_defined?(:RDOC_OPTIONS)
    gem_options[:rdoc_options] ||= RDOC_OPTIONS[:options]
    rdoc_files                   = RDOC_OPTIONS[:rdoc_files]
  end

  gem_spec = Gem::Specification.new { |spec|

    ### name

    gem_options[:name] ||= rf_config[:package]

    abort 'Gem name missing' unless gem_options[:name]

    ### version

    abort 'Gem version missing' unless gem_options[:version]

    if gem_options.delete(:append_svnversion) && svnversion = `svnversion`[/\d+/]
      gem_options[:version] << '.' << svnversion
    end

    ### author(s)

    if author = gem_options.delete(:author)
      gem_options[:authors] ||= [author]
    end

    ### description

    gem_options[:description] ||= gem_options[:summary]

    ### rubyforge project, homepage

    gem_options[:rubyforge_project] ||= rf_config[:project]

    if rf_project = gem_options[:rubyforge_project] and !rf_project.empty?
      rdoc_dir = rf_config[:rdoc_dir] == :package ?
        rf_config[:package] || gem_options[:name] : RDOC_OPTIONS[:rdoc_dir]

      gem_options[:homepage] ||= "#{rf_project}.rubyforge.org/#{rdoc_dir}"
    end

    if gem_options[:homepage] && gem_options[:homepage] !~ %r{://}
      gem_options[:homepage] = 'http://' << gem_options[:homepage]
    end

    ### extra_rdoc_files, files, executables, bindir

    gem_options[:files]            ||= []
    gem_options[:extra_rdoc_files] ||= rdoc_files - gem_options[:files] if rdoc_files
    gem_options[:files]             += gem_options.delete(:extra_files) || []

    gem_options[:executables] ||= gem_options[:files].grep(/\Abin\//)

    [:extra_rdoc_files, :files, :executables].each { |files|
      gem_options[files].delete_if { |file| !File.exists?(file) }
    }

    unless gem_options[:executables].empty?
      gem_options[:bindir] ||= File.dirname(gem_options[:executables].first)
      gem_options[:executables].map! { |executable| File.basename(executable) }
    end

    ### dependencies

    (gem_options.delete(:dependencies) || []).each { |dependency|
      spec.add_dependency(*dependency)
    }

    ### => set options!

    gem_options.each { |option, value|
      spec.send("#{option}=", value)
    }
  }

  desc 'Display the gem specification'
  task :gemspec do
    puts gem_spec.to_ruby
  end

  desc "Update (or create) the project's gemspec file"
  task 'gemspec:update' do
    file = "#{gem_spec.name}.gemspec"
    action = File.exists?(file) ? 'Updated' : 'Created'

    File.open(file, 'w') { |f| f.puts gem_spec.to_ruby }

    puts "#{action} #{file}"
  end

  pkg_task = Rake::GemPackageTask.new(gem_spec) do |pkg|
    pkg.need_tar_gz = true
    pkg.need_zip    = true

    if defined?(ZIP_COMMANDS)
      require 'nuggets/file/which'
      pkg.zip_command = File.which_command(ZIP_COMMANDS) || ZIP_COMMANDS.first
    end
  end

begin
  rubyforge do |rf_config, rf_pool|

    desc 'Package and upload the release to RubyForge'
    task :release => [:package, :publish_docs] do
      files = Dir[File.join(pkg_task.package_dir, "#{pkg_task.package_name}.*")]
      abort 'Nothing to release!' if files.empty?

      # shorten to (at most) three digits
      version = pkg_task.version.to_s.split(/([.])/)[0..4].join

      rf = rf_pool.call

      # TODO: Add release notes and changes.
      #uc = rf.userconfig
      #uc['release_notes']   = description if description
      #uc['release_changes'] = changes if changes
      #uc['preformatted']    = true

      rf.add_release(rf_config[:project], pkg_task.name, version, *files)
    end

  end
rescue RuntimeError => err
  raise unless err.to_s == 'Skipping RubyForge tasks'

  gemcutter do |gc_pool|

    desc 'Create the gem and upload it to RubyGems.org'
    task :release => [:gem] do
      gc = gc_pool.call
      gc.push(File.join(pkg_task.package_dir, pkg_task.gem_file))
    end

  end
end

end
