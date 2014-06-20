$:.unshift(File.expand_path('../lib', __FILE__))

require 'hen'

Hen.lay! {{
  :gem => {
    :name         => %q{hen},
    :version      => Hen::VERSION,
    :summary      => %q{Just another project helper that integrates with Rake.},
    :description  => %q{A Rake helper framework, similar to Hoe or Echoe.},
    :author       => %q{Jens Wille},
    :email        => %q{jens.wille@gmail.com},
    :license      => %q{AGPL-3.0},
    :homepage     => :blackwinter,
    :extra_files  => FileList['lib/hens/*.rake'].to_a,
    :dependencies => %w[highline nuggets safe_yaml]
  }
}}
