Hen :spec do
  require 'spec/rake/spectask'

  spec_options = config[:spec]

  spec_files =
    spec_options.delete(:files) || FileList[spec_options.delete(:pattern)]

  if spec_files && !spec_files.empty?
    Spec::Rake::SpecTask.new { |t|
      t.spec_files = spec_files
      t.spec_opts  = spec_options.map { |option, value|
        option = '--' << option.to_s.tr('_', '-')
        value.is_a?(String) ? [option, value] : value ? option : nil
      }.compact.flatten
    }
  end
end
