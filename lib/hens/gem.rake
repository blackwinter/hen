# Use RDOC_OPTIONS from 'rdoc.rake'
Hen :gem => :rdoc do |hen|
  hen.requires :gem_spec

  require 'rake/gempackagetask'

  GEM_DEFAULTS = hen[:gem] unless Object.const_defined?(:GEM_DEFAULTS)

  gem_options = GEM_DEFAULTS.merge(hen.call(:gem_spec))

  if Object.const_defined?(:RDOC_OPTIONS)
    gem_options[:rdoc_options] ||= RDOC_OPTIONS[:options]
    rdoc_files                   = RDOC_OPTIONS[:rdoc_files]
  end

  spec = Gem::Specification.new { |gem_spec|
    (gem_options.delete(:dependencies) || []).each { |dependency|
      gem_spec.add_dependency(*dependency)
    }

    if gem_options.has_key?(:version)
      gem_version = gem_options.delete(:version).dup
    else
      abort "Gem version missing"
    end

    if gem_options.delete(:append_svnversion) && svnversion = `svnversion`.chomp[/\d+/]
      gem_version << '.' << svnversion
    end

    gem_spec.version = gem_version

    if rubyforge_project = gem_options[:rubyforge_project]
      gem_spec.homepage = gem_options.delete(:homepage) ||
        "#{rubyforge_project}.rubyforge.org/#{gem_options[:name]}"
    end

    files            = gem_options.delete(:files)       || []
    extra_files      = gem_options.delete(:extra_files) || []
    executable_files = gem_options.delete(:executables) || files.grep(/\Abin\//)

    unless executable_files.empty?
      gem_spec.executables = executable_files.map { |executable|
        File.basename(executable)
      }

      gem_spec.bindir = File.dirname(executable_files.first)
    end

    gem_spec.extra_rdoc_files =
      gem_options.delete(:extra_rdoc_files) || rdoc_files - files

    gem_spec.files = files + extra_files

    gem_options.each { |option, value|
      gem_spec.send("#{option}=", value)
    }
  }

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
  end

  desc 'Upload latest gem to Rubyforge'
  task :upload_gem => :gem do
    require 'rubyforge'

    rf = RubyForge.new
    rf.login

    # shorten to (at most) three digits
    version = spec.version.to_s.split(/([.])/)[0..4].join

    latest_gem = Dir['pkg/*.gem'].sort_by { |gem|
      File.mtime(gem)
    }.last

    rf.add_release spec.rubyforge_project, spec.name, version, latest_gem
  end

  desc 'Upload latest gem to gem server'
  task :upload_gem_to_server => :gem do
    host = ENV['GEM_HOST'] || 'prometheus.khi.uni-koeln.de'
    user = ENV['GEM_USER'] || 'prometheus'
    path = ENV['GEM_PATH'] || '/var/www/rubygems'
    temp = ENV['GEM_TEMP'] || File.join(path, 'tmp')

    latest_gem = Dir['pkg/*.gem'].sort_by { |gem|
      File.mtime(gem)
    }.last

    sh "scp #{latest_gem} #{user}@#{host}:#{path}/gems"
    sh "ssh #{user}@#{host} 'TMPDIR='#{temp}' gem generate_index -d #{path} -V'"
  end

end
