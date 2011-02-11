# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hen}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2011-02-11}
  s.default_executable = %q{hen}
  s.description = %q{Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["hen"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/hen/cli.rb", "lib/hen/version.rb", "lib/hen/dsl.rb", "lib/hen.rb", "bin/hen", "lib/hens/rdoc.rake", "lib/hens/gem.rake", "lib/hens/test.rake", "lib/hens/spec.rake", "README", "ChangeLog", "Rakefile", "COPYING", "example/hens/sample.rake", "example/_henrc", "example/project/README", "example/project/ChangeLog", "example/project/Rakefile", "example/project/lib/__progname__/version.rb", "example/project/lib/__progname__.rb", "example/project/_gitignore", "example/project/COPYING"]
  s.homepage = %q{http://prometheus.rubyforge.org/hen}
  s.rdoc_options = ["--line-numbers", "--charset", "UTF-8", "--all", "--main", "README", "--title", "hen Application documentation (v0.3.1)"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style.}

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
