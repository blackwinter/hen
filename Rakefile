$:.unshift('lib')

require 'hen'
require 'hen/version'

task(:doc_spec) {{
  :title => 'hen Application documentation',
}}

task(:gem_spec) {{
  :name              => 'hen',
  :version           => Hen::VERSION,
  :rubyforge_project => 'prometheus',
  :summary           => "Hoe or Echoe? No, thanks! Just a Rake helper " <<
                        "that fits my own personal style.",
  :files             => FileList['lib/**/*.rb', 'bin/*'].to_a,
  :extra_files       => FileList['[A-Z]*', 'lib/hens/*.rake', 'example/*', 'example/.henrc'].to_a
}}

Hen.lay
