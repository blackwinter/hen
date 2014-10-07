# -*- encoding: utf-8 -*-
# stub: hen 0.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "hen"
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2014-10-07"
  s.description = "A Rake helper framework, similar to Hoe or Echoe."
  s.email = "jens.wille@gmail.com"
  s.executables = ["hen"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "bin/hen", "example/_henrc", "example/hens/sample.rake", "example/project/COPYING", "example/project/ChangeLog", "example/project/README", "example/project/Rakefile", "example/project/_gitignore", "example/project/_travis.yml", "example/project/lib/__progname__.rb", "example/project/lib/__progname__/version.rb", "lib/hen.rb", "lib/hen/cli.rb", "lib/hen/commands.rb", "lib/hen/dsl.rb", "lib/hen/version.rb", "lib/hens/gem.rake", "lib/hens/rdoc.rake", "lib/hens/spec.rake", "lib/hens/test.rake"]
  s.homepage = "http://github.com/blackwinter/hen"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nhen-0.7.0 [2014-10-07]:\n\n* Require at least Ruby 1.9.3.\n* Task <tt>doc:publish:github</tt> cleans up before adding new files.\n* Task <tt>doc:publish:github</tt> performs local clone and shallow checkout\n  instead of fetching the full history.\n* When setting +post_install_message+, gem files are searched for log file;\n  specify +HEN_CHANGELOG+ to override.\n\n"
  s.rdoc_options = ["--title", "hen Application documentation (v0.7.0)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.2"
  s.summary = "Just another project helper that integrates with Rake."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>, ["~> 1.6"])
      s.add_runtime_dependency(%q<nuggets>, ["~> 1.0"])
      s.add_runtime_dependency(%q<safe_yaml>, ["~> 1.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<highline>, ["~> 1.6"])
      s.add_dependency(%q<nuggets>, ["~> 1.0"])
      s.add_dependency(%q<safe_yaml>, ["~> 1.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<highline>, ["~> 1.6"])
    s.add_dependency(%q<nuggets>, ["~> 1.0"])
    s.add_dependency(%q<safe_yaml>, ["~> 1.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
