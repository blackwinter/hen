# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hen}
  s.version = "0.3.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jens Wille}]
  s.date = %q{2011-05-24}
  s.description = %q{Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = [%q{hen}]
  s.extra_rdoc_files = [%q{README}, %q{COPYING}, %q{ChangeLog}]
  s.files = [%q{lib/hen/cli.rb}, %q{lib/hen/version.rb}, %q{lib/hen/dsl.rb}, %q{lib/hen.rb}, %q{bin/hen}, %q{lib/hens/rdoc.rake}, %q{lib/hens/gem.rake}, %q{lib/hens/test.rake}, %q{lib/hens/spec.rake}, %q{README}, %q{ChangeLog}, %q{Rakefile}, %q{COPYING}, %q{example/hens/sample.rake}, %q{example/_henrc}, %q{example/project/README}, %q{example/project/ChangeLog}, %q{example/project/Rakefile}, %q{example/project/lib/__progname__/version.rb}, %q{example/project/lib/__progname__.rb}, %q{example/project/_gitignore}, %q{example/project/COPYING}]
  s.homepage = %q{http://prometheus.rubyforge.org/hen}
  s.rdoc_options = [%q{--charset}, %q{UTF-8}, %q{--title}, %q{hen Application documentation (v0.3.9)}, %q{--main}, %q{README}, %q{--line-numbers}, %q{--all}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.8.3}
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
