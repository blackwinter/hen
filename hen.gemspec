# -*- encoding: utf-8 -*-
# stub: hen 0.4.8 ruby lib

Gem::Specification.new do |s|
  s.name = "hen"
  s.version = "0.4.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = "2013-10-21"
  s.description = "Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style."
  s.email = "jens.wille@gmail.com"
  s.executables = ["hen"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/hen.rb", "lib/hen/cli.rb", "lib/hen/dsl.rb", "lib/hen/version.rb", "bin/hen", "lib/hens/gem.rake", "lib/hens/rdoc.rake", "lib/hens/spec.rake", "lib/hens/test.rake", "COPYING", "ChangeLog", "README", "Rakefile", "example/_henrc", "example/hens/sample.rake", "example/project/COPYING", "example/project/ChangeLog", "example/project/README", "example/project/Rakefile", "example/project/_gitignore", "example/project/lib/__progname__.rb", "example/project/lib/__progname__/version.rb"]
  s.homepage = "http://github.com/blackwinter/hen"
  s.licenses = ["AGPL"]
  s.post_install_message = "\nhen-0.4.8 [2013-07-15]:\n\n* Fall back to first local RDoc file for initial page.\n* Specify project and template license in GemSpec.\n* Housekeeping.\n\n"
  s.rdoc_options = ["--charset", "UTF-8", "--line-numbers", "--all", "--title", "hen Application documentation (v0.4.8)", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.9"
  s.summary = "Hoe or Echoe? No, thanks! Just a Rake helper that fits my own personal style."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.8.4"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
    else
      s.add_dependency(%q<ruby-nuggets>, [">= 0.8.4"])
      s.add_dependency(%q<highline>, [">= 0"])
    end
  else
    s.add_dependency(%q<ruby-nuggets>, [">= 0.8.4"])
    s.add_dependency(%q<highline>, [">= 0"])
  end
end
