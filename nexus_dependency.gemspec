# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nexus_dependency}
  s.version = "1.0.0.20101025185739"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Dalessio"]
  s.date = %q{2010-10-25}
  s.description = %q{FIX (describe your package)}
  s.email = ["mike.dalessio@gmail.com"]
  s.extra_rdoc_files = ["Manifest.txt"]
  s.files = [".autotest", "History.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "lib/nexus_dependency.rb", "spec/spec_helper.rb", "spec/nexus_dependency/rake_spec.rb"]
  s.homepage = %q{FIX (url)}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{nexus_dependency}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{FIX (describe your package)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0.8.7"])
      s.add_runtime_dependency(%q<rnexus>, [">= 0.0.6"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<rspec>, ["~> 1"])
      s.add_development_dependency(%q<hoe>, [">= 2.6.1"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.7"])
      s.add_dependency(%q<rnexus>, [">= 0.0.6"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<rspec>, ["~> 1"])
      s.add_dependency(%q<hoe>, [">= 2.6.1"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.7"])
    s.add_dependency(%q<rnexus>, [">= 0.0.6"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<rspec>, ["~> 1"])
    s.add_dependency(%q<hoe>, [">= 2.6.1"])
  end
end
