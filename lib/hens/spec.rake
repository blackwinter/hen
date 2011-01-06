Hen :spec do

  begin
    require 'rspec/core/rake_task'
  rescue LoadError
    require 'spec/rake/spectask'
  end

  spec_options = config[:spec]

  spec_files = spec_options.delete(:files) || FileList[spec_options.delete(:pattern)]

  if spec_files && !spec_files.empty?
    if spec_helper = spec_options.delete(:helper) and File.readable?(spec_helper)
      spec_files.delete(spec_helper)
      spec_files.unshift(spec_helper)
    end

    opts_file = spec_options.delete(:options)

    spec_opts = spec_options.map { |option, value|
      option = '--' << option.to_s.tr('_', '-')
      value.is_a?(String) ? [option, value] : value ? option : nil
    }.compact.flatten

    if opts_file && File.readable?(opts_file)
      File.readlines(opts_file).each { |l| spec_opts << l.chomp }
    end

    klass, spec_task = if defined?(RSpec::Core::RakeTask)
      [RSpec::Core::RakeTask, lambda { |t|
        t.pattern    = spec_files
        t.rspec_opts = spec_opts
      }]
    else
      [Spec::Rake::SpecTask, lambda { |t|
        t.spec_files = spec_files
        t.spec_opts  = spec_opts
      }]
    end

    klass.new(&spec_task)

    rcov_opts = ['--exclude', spec_files.join(',')]
    rcov_file = File.join(spec_files.first[/[^\/.]+/], 'rcov.opts')

    if rcov_file && File.readable?(rcov_file)
      File.readlines(rcov_file).each { |l| rcov_opts << l.chomp }
    end

    #desc "Run specs with RCov"
    klass.new('spec:rcov') do |t|
      spec_task[t]

      t.rcov = true
      t.rcov_opts = rcov_opts
    end
  end

end
