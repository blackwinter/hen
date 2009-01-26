Hen :spec do

  require 'spec/rake/spectask'

  spec_options = config[:spec]

  spec_files = spec_options.delete(:files) || FileList[spec_options.delete(:pattern)]

  if spec_files && !spec_files.empty?
    if spec_helper = spec_options.delete(:helper) and File.readable?(spec_helper)
      spec_files.delete(spec_helper)
      spec_files.unshift(spec_helper)
    end

    spec_options.delete(:options) unless File.readable?(spec_options[:options])

    spec_opts = spec_options.map { |option, value|
      option = '--' << option.to_s.tr('_', '-')
      value.is_a?(String) ? [option, value] : value ? option : nil
    }.compact.flatten

    spec_task = lambda { |t|
      t.spec_files = spec_files
      t.spec_opts  = spec_opts
    }

    Spec::Rake::SpecTask.new(&spec_task)

    #desc "Run specs with RCov"
    Spec::Rake::SpecTask.new('spec:rcov') do |t|
      spec_task[t]

      t.rcov = true
      t.rcov_opts = ['--exclude', spec_files.join(',')]
    end
  end

end
