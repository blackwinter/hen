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
    :homepage     => :blackwinter,
    :extra_files  => FileList['lib/hens/*.rake'].to_a,
    :dependencies => [['ruby-nuggets', '>= 0.8.4'], 'highline']
  }
}}
