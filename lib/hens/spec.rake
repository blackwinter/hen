Hen :spec do

  spec_options = {
    :pattern => 'spec/**/*_spec.rb',
    :helper  => 'spec/spec_helper.rb',
    :options => 'spec/spec.opts'
  }.update(config[:spec])

  spec_klass = begin
    raise LoadError if spec_options.delete(:legacy)

    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask
  rescue LoadError
    require 'spec/rake/spectask'
    Spec::Rake::SpecTask
  end

  spec_files = spec_options.delete(:files) ||
      FileList[spec_options.delete(:pattern)].to_a

  mangle_files!(spec_files, :managed => false)

  unless spec_files.empty?
    spec_helper = spec_options.delete(:helper)

    if spec_helper && File.readable?(spec_helper)
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

    spec_block = lambda { |t|
      if t.respond_to?(:spec_files=)
        t.spec_files = spec_files
        t.spec_opts  = spec_opts
      else
        t.pattern    = spec_files
        t.rspec_opts = spec_opts
      end
    }

    spec_klass.new(&spec_block)

    rcov_opts = ['--exclude', spec_files.join(',')]
    rcov_file = File.join(spec_files.first[%r{[^/.]+}], 'rcov.opts')

    if rcov_file && File.readable?(rcov_file)
      File.readlines(rcov_file).each { |line| rcov_opts << line.chomp }
    end

    #desc "Run specs with RCov"
    klass.new('spec:rcov') do |t|
      spec_block[t]

      t.rcov = true
      t.rcov_opts = rcov_opts
    end
  end

end
