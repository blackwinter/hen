# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hen"
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = "2011-09-21"
  s.description = "Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style."
  s.email = "jens.wille@uni-koeln.de"
  s.executables = ["hen"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/hen/dsl.rb", "lib/hen/version.rb", "lib/hen/cli.rb", "lib/hen.rb", "bin/hen", "lib/hens/rdoc.rake", "lib/hens/test.rake", "lib/hens/gem.rake", "lib/hens/spec.rake", "ChangeLog", "COPYING", "README", "Rakefile", "example/hens/sample.rake", "example/_henrc", "example/project/ChangeLog", "example/project/_gitignore", "example/project/COPYING", "example/project/lib/__progname__/version.rb", "example/project/lib/__progname__.rb", "example/project/README", "example/project/Rakefile"]
  s.homepage = "http://prometheus.rubyforge.org/hen"
  s.rdoc_options = ["--main", "README", "--all", "--charset", "UTF-8", "--title", "hen Application documentation (v0.4.0)", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "prometheus"
  s.rubygems_version = "1.8.10"
  s.summary = "Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.6.9"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
    else
      s.add_dependency(%q<ruby-nuggets>, [">= 0.6.9"])
      s.add_dependency(%q<highline>, [">= 0"])
    end
  else
    s.add_dependency(%q<ruby-nuggets>, [">= 0.6.9"])
    s.add_dependency(%q<highline>, [">= 0"])
  end
end
