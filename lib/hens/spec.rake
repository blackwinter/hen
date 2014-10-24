Hen :spec do

  spec_options = {
    pattern: 'spec/**/*_spec.rb',
    helper:  'spec/spec_helper.rb',
    options: 'spec/spec.opts'
  }.update(config[:spec])

  spec_files = spec_options.delete(:files) ||
      FileList[spec_options.delete(:pattern)].to_a

  mangle_files!(spec_files, managed: false)

  unless spec_files.empty?
    require 'rspec/core/rake_task'

    spec_helper = spec_options.delete(:helper)

    if spec_helper && File.readable?(spec_helper)
      spec_files.delete(spec_helper)
      (spec_options[:require] ||= []) << File.basename(spec_helper, '.rb')
    end

    opts_file = spec_options.delete(:options)
    spec_opts = map_options(spec_options)

    if opts_file && File.readable?(opts_file)
      File.readlines(opts_file).each { |line| spec_opts << line.chomp }
    end

    RSpec::Core::RakeTask.new { |t|
      t.pattern    = spec_files
      t.rspec_opts = spec_opts
    }
  end

end
