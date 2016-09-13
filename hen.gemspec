# -*- encoding: utf-8 -*-
# stub: hen 0.8.6 ruby lib

Gem::Specification.new do |s|
  s.name = "hen".freeze
  s.version = "0.8.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jens Wille".freeze]
  s.date = "2016-09-13"
  s.description = "A Rake helper framework, similar to Hoe or Echoe.".freeze
  s.email = "jens.wille@gmail.com".freeze
  s.executables = ["hen".freeze]
  s.extra_rdoc_files = ["README".freeze, "CONDUCT".freeze, "COPYING".freeze, "ChangeLog".freeze]
  s.files = ["CONDUCT".freeze, "COPYING".freeze, "ChangeLog".freeze, "README".freeze, "Rakefile".freeze, "bin/hen".freeze, "example/_henrc".freeze, "example/hens/sample.rake".freeze, "example/project/CONDUCT".freeze, "example/project/COPYING".freeze, "example/project/ChangeLog".freeze, "example/project/README".freeze, "example/project/Rakefile".freeze, "example/project/_gitignore".freeze, "example/project/_travis.yml".freeze, "example/project/lib/__progname__.rb".freeze, "example/project/lib/__progname__/version.rb".freeze, "lib/hen.rb".freeze, "lib/hen/cli.rb".freeze, "lib/hen/commands.rb".freeze, "lib/hen/dsl.rb".freeze, "lib/hen/version.rb".freeze, "lib/hens/gem.rake".freeze, "lib/hens/rdoc.rake".freeze, "lib/hens/spec.rake".freeze, "lib/hens/test.rake".freeze]
  s.homepage = "http://github.com/blackwinter/hen".freeze
  s.licenses = ["AGPL-3.0".freeze]
  s.post_install_message = "\nhen-0.8.6 [2016-09-13]:\n\n* Fixed regression introduced in 0.8.4.\n\n".freeze
  s.rdoc_options = ["--title".freeze, "hen Application documentation (v0.8.6)".freeze, "--charset".freeze, "UTF-8".freeze, "--line-numbers".freeze, "--all".freeze, "--main".freeze, "README".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "2.6.6".freeze
  s.summary = "Just another project helper that integrates with Rake.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>.freeze, ["~> 1.7"])
      s.add_runtime_dependency(%q<nuggets>.freeze, ["~> 1.5"])
      s.add_runtime_dependency(%q<safe_yaml>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<highline>.freeze, ["~> 1.7"])
      s.add_dependency(%q<nuggets>.freeze, ["~> 1.5"])
      s.add_dependency(%q<safe_yaml>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<highline>.freeze, ["~> 1.7"])
    s.add_dependency(%q<nuggets>.freeze, ["~> 1.5"])
    s.add_dependency(%q<safe_yaml>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
