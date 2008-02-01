$:.unshift('lib')

require 'hen'

Hen.lay! {{
  :rubyforge => {
    :package => 'hen'
  },

  :gem => {
    :version      => Hen::VERSION,
    :summary      => "Hoe or Echoe? No, thanks! Just a Rake " <<
                     "helper that fits my own personal style.",
    :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
    :extra_files  => FileList['[A-Z]*', 'lib/hens/*.rake', 'example/*', 'example/.henrc'].to_a,
    :dependencies => ['rubyforge', ['ruby-nuggets', '>= 0.0.7']]
  }
}}
