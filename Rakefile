$:.unshift(File.expand_path('../lib', __FILE__))

require 'hen'

Hen.lay! {{
  :gem => {
    :name         => %q{hen},
    :version      => Hen::VERSION,
    :summary      => "Hoe or Echoe? No, thanks! Just a Rake " <<
                     "helper that fits my own personal style.",
    :author       => %q{Jens Wille},
    :email        => %q{jens.wille@gmail.com},
    :license      => %q{AGPL-3.0},
    :homepage     => :blackwinter,
    :extra_files  => FileList['lib/hens/*.rake'].to_a,
    :dependencies => %w[highline safe_yaml] << ['ruby-nuggets', '>= 0.8.4']
  }
}}
