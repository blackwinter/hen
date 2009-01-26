# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hen}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2009-01-26}
  s.default_executable = %q{hen}
  s.description = %q{Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["hen"]
  s.extra_rdoc_files = ["COPYING", "ChangeLog", "README"]
  s.files = ["lib/hen.rb", "lib/hen/cli.rb", "lib/hen/dsl.rb", "lib/hen/version.rb", "bin/hen", "Rakefile", "COPYING", "ChangeLog", "README", "lib/hens/rdoc.rake", "lib/hens/gem.rake", "lib/hens/test.rake", "lib/hens/spec.rake", "example/hens", "example/hens/sample.rake", "example/project", "example/project/Rakefile", "example/project/COPYING", "example/project/ChangeLog", "example/project/lib", "example/project/lib/__progname__", "example/project/lib/__progname__/version.rb", "example/project/lib/__progname__.rb", "example/project/README", "example/.henrc"]
  s.has_rdoc = true
  s.homepage = %q{http://prometheus.rubyforge.org/hen}
  s.rdoc_options = ["--inline-source", "--title", "hen Application documentation", "--charset", "UTF-8", "--main", "README", "--all", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubyforge>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.3.3"])
    else
      s.add_dependency(%q<rubyforge>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0.3.3"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0.3.3"])
  end
end
