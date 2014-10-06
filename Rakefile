require_relative 'lib/hen'

Hen.lay! {{
  gem: {
    name:         %q{hen},
    version:      Hen::VERSION,
    summary:      %q{Just another project helper that integrates with Rake.},
    description:  %q{A Rake helper framework, similar to Hoe or Echoe.},
    author:       %q{Jens Wille},
    email:        %q{jens.wille@gmail.com},
    license:      %q{AGPL-3.0},
    homepage:     :blackwinter,
    extra_files:  FileList['lib/hens/*.rake'].to_a,
    dependencies: {
      highline:  '~> 1.6',
      nuggets:   '~> 1.0',
      safe_yaml: '~> 1.0'
    },

    required_ruby_version: '>= 1.9.3'
  }
}}
