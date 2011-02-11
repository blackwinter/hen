# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hen}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2011-02-11}
  s.default_executable = %q{hen}
  s.description = %q{Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["hen"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/hen/dsl.rb", "lib/hen/version.rb", "lib/hen/cli.rb", "lib/hen.rb", "bin/hen", "lib/hens/gem.rake", "lib/hens/test.rake", "lib/hens/spec.rake", "lib/hens/rdoc.rake", "COPYING", "Rakefile", "README", "ChangeLog", "example/hens/sample.rake", "example/_henrc", "example/project/COPYING", "example/project/Rakefile", "example/project/_gitignore", "example/project/README", "example/project/ChangeLog", "example/project/lib/__progname__/version.rb", "example/project/lib/__progname__.rb"]
  s.homepage = %q{http://prometheus.rubyforge.org/hen}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README", "--charset", "UTF-8", "--title", "hen Application documentation (v0.3.2)", "--all"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.4.2}
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
