# Use RDOC_OPTIONS from 'rdoc.rake'
Hen :gem => :rdoc do
  require 'rake/gempackagetask'

  gem_options = config[:gem]
  rubyforge   = config[:rubyforge]

  if Object.const_defined?(:RDOC_OPTIONS)
    gem_options[:rdoc_options] ||= RDOC_OPTIONS[:options]
    rdoc_files                   = RDOC_OPTIONS[:rdoc_files]
  end

  gem_spec = Gem::Specification.new { |spec|

    ### name

    gem_options[:name] ||= rubyforge[:package]

    abort "Gem name missing" unless gem_options[:name]

    ### version

    abort 'Gem version missing' unless gem_options[:version]

    if gem_options.delete(:append_svnversion) && svnversion = `svnversion`.chomp[/\d+/]
      gem_options[:version] << '.' << svnversion
    end

    ### description

    gem_options[:description] ||= gem_options[:summary]

    ### rubyforge project, homepage

    gem_options[:rubyforge_project] ||= rubyforge[:project]

    if rf_project = gem_options[:rubyforge_project]
      gem_options[:homepage] ||= "#{rf_project}.rubyforge.org/#{gem_options[:name]}"
    end

    if gem_options[:homepage] && gem_options[:homepage] !~ /:\/\//
      gem_options[:homepage] = 'http://' << gem_options[:homepage]
    end

    ### extra_rdoc_files, files, executables, bindir

    gem_options[:files]            ||= []
    gem_options[:extra_rdoc_files] ||= rdoc_files - gem_options[:files] if rdoc_files
    gem_options[:files]             += gem_options.delete(:extra_files) || []

    gem_options[:executables] ||= gem_options[:files].grep(/\Abin\//)
    gem_options[:bindir]      ||= File.dirname(gem_options[:executables].first)

    gem_options[:executables].map! { |executable| File.basename(executable) }

    ### dependencies

    (gem_options.delete(:dependencies) || []).each { |dependency|
      spec.add_dependency(*dependency)
    }

    ### => set options!

    gem_options.each { |option, value|
      spec.send("#{option}=", value)
    }
  }

  desc "Display the gem specification"
  task :debug_gem do
    puts gem_spec.to_ruby
  end

  pkg_task = Rake::GemPackageTask.new(gem_spec) do |pkg|
    pkg.need_tar_gz = true
    pkg.need_zip    = true
  end

  desc "Package and upload the release to Rubyforge"
  task :release => [:package, :publish_docs] do
    rf = init_rubyforge

    files = Dir[File.join('pkg', "#{pkg_task.package_name}.*")]
    abort "Nothing to release!" if files.empty?

    # shorten to (at most) three digits
    version = pkg_task.version.to_s.split(/([.])/)[0..4].join

    rf.add_release rubyforge[:project], pkg_task.name, version, *files
  end

end
