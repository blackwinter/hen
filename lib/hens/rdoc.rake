Hen :rdoc do |hen|
  hen.requires :doc_spec

  require 'rake/rdoctask'

  RDOC_DEFAULTS = hen[:rdoc] unless Object.const_defined?(:RDOC_DEFAULTS)

  unless Object.const_defined?(:RDOC_OPTIONS)
    opts = RDOC_DEFAULTS.merge(hen.call(:doc_spec))

    RDOC_OPTIONS = {
      :rdoc_dir   => opts.delete(:rdoc_dir),
      :rdoc_files => FileList[opts.delete(:rdoc_files)].to_a.uniq,
      :options    => opts.map { |option, value|
        option = '--' << option.to_s.tr('_', '-')
        value.is_a?(String) ? [option, value] : value ? option : nil
      }.compact.flatten
    }
  end

  Rake::RDocTask.new(:doc) { |rdoc|
    opts = RDOC_OPTIONS

    rdoc.rdoc_dir   = opts[:rdoc_dir]
    rdoc.rdoc_files = opts[:rdoc_files]
    rdoc.options    = opts[:options]
  }

end