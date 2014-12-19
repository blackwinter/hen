# -*- encoding: utf-8 -*-
# stub: hen 0.8.1 ruby lib

Gem::Specification.new do |s|
  s.name = "hen"
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2014-12-19"
  s.description = "A Rake helper framework, similar to Hoe or Echoe."
  s.email = "jens.wille@gmail.com"
  s.executables = ["hen"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "bin/hen", "example/_henrc", "example/hens/sample.rake", "example/project/COPYING", "example/project/ChangeLog", "example/project/README", "example/project/Rakefile", "example/project/_gitignore", "example/project/_travis.yml", "example/project/lib/__progname__.rb", "example/project/lib/__progname__/version.rb", "lib/hen.rb", "lib/hen/cli.rb", "lib/hen/commands.rb", "lib/hen/dsl.rb", "lib/hen/version.rb", "lib/hens/gem.rake", "lib/hens/rdoc.rake", "lib/hens/spec.rake", "lib/hens/test.rake"]
  s.homepage = "http://github.com/blackwinter/hen"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nhen-0.8.1 [2014-12-19]:\n\n* Removed workaround for RDoc issue 330. Implemented in RDoc 4.2.0.\n* Renamed cross compile option +ruby_versions+ to +cross_ruby_versions+;\n  defaults to all versions defined in rake-compiler's <tt>config.yml</tt>.\n* When +cross_config_options+ given, cross compilation is implicitly disabled\n  when they are empty or enabled when they are non-empty; override by setting\n  +cross_compile+ explicitly.\n* Added support for <tt>with_cross_<library></tt> options; specify a proc that\n  accepts the <tt>WITH_CROSS_<LIBRARY></tt> environment variable, if set, and\n  returns a single directory for <tt>--with-<library>-dir</tt> or an array for\n  <tt>--with-<library>-include</tt> and <tt>--with-<library>-lib</tt> to be\n  added to +cross_config_options+.\n* Added support for +cross_compiling+ option.\n* Added support for +local_files+ option, i.e., generated files that should be\n  included in the package but not under version control.\n* When determining the +ext_name+ option, a possible <tt>ruby-</tt> prefix is\n  ignored.\n\n"
  s.rdoc_options = ["--title", "hen Application documentation (v0.8.1)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.5"
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
