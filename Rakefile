$:.unshift('lib')

require 'hen'

Hen.lay! {{
  :gem => {
    :name         => 'hen',
    :version      => Hen::VERSION,
    :summary      => "Hoe or Echoe? No, thanks! Just a Rake " <<
                     "helper that fits my own personal style.",
    :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
    :extra_files  => FileList['[A-Z]*', 'lib/hens/*.rake', 'example/**/*', 'example/.henrc'].to_a,
    :dependencies => [['ruby-nuggets', '>= 0.3.3'], 'highline']
  }
}}
