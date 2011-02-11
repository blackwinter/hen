$:.unshift(File.expand_path('../lib', __FILE__))

require 'hen'

Hen.lay! {{
  :rubyforge => {
    :project => %q{prometheus},
    :package => %q{hen}
  },

  :gem => {
    :version      => Hen::VERSION,
    :summary      => "Hoe or Echoe? No, thanks! Just a Rake " <<
                     "helper that fits my own personal style.",
    :author       => %q{Jens Wille},
    :email        => %q{jens.wille@uni-koeln.de},
    :extra_files  => FileList['lib/hens/*.rake'].to_a,
    :dependencies => [['ruby-nuggets', '>= 0.6.9'], 'highline']
  }
}}
