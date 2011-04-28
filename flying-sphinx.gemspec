# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flying-sphinx}
  s.version = "0.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.authors = ["Pat Allan"]
  s.email   = %q{pat@freelancing-gods.com}
  s.date    = %q{2011-02-07}
  s.summary = %q{Sphinx in the Cloud}
  s.description = %q{Hooks Thinking Sphinx into the Flying Sphinx service}
  s.homepage = %q{https://flying-sphinx.com}

  s.extra_rdoc_files = ["README.textile"]
  s.files = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.rubygems_version = %q{1.3.7}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thinking-sphinx>, [">= 0"])
      s.add_runtime_dependency(%q<net-ssh>,         ["~> 2.0.23"])
      s.add_runtime_dependency(%q<multi_json>,      ["~> 1.0.0"])
      s.add_runtime_dependency(%q<faraday>,         ["~> 0.6.1"])
      s.add_runtime_dependency(%q<faraday_middleware>, ["~> 0.6.3"])
      s.add_runtime_dependency(%q<rash>,            ["~> 0.3.0"])
      s.add_development_dependency(%q<yajl-ruby>,   ["~> 0.8.2"])
      s.add_development_dependency(%q<rspec>,       ["~> 2.5.0"])
      s.add_development_dependency(%q<rcov>,        ["~> 0.9.9"])
      s.add_development_dependency(%q<fakeweb>,     ["~> 1.3.0"])
      s.add_development_dependency(%q<fakeweb-matcher>, ["~> 1.2.2"])
      s.add_development_dependency(%q<delayed_job>, ["~> 2.1.4"])
    else
      s.add_dependency(%q<thinking-sphinx>, [">= 0"])
      s.add_dependency(%q<net-ssh>,         ["~> 2.0.23"])
      s.add_dependency(%q<multi_json>,      ["~> 1.0.0"])
      s.add_dependency(%q<faraday>,         ["~> 0.6.1"])
      s.add_dependency(%q<faraday_middleware>, ["~> 0.6.3"])
      s.add_dependency(%q<rash>,            ["~> 0.3.0"])
      s.add_dependency(%q<yajl-ruby>,       ["~> 0.8.2"])
      s.add_dependency(%q<rspec>,           ["~> 2.5.0"])
      s.add_dependency(%q<rcov>,            ["~> 0.9.9"])
      s.add_dependency(%q<fakeweb>,         ["~> 1.3.0"])
      s.add_dependency(%q<fakeweb-matcher>, ["~> 1.2.2"])
      s.add_dependency(%q<delayed_job>,     ["~> 2.1.4"])
    end
  else
    s.add_dependency(%q<thinking-sphinx>, [">= 0"])
    s.add_dependency(%q<net-ssh>,         ["~> 2.0.23"])
    s.add_dependency(%q<multi_json>,      ["~> 1.0.0"])
    s.add_dependency(%q<faraday>,         ["~> 0.6.1"])
    s.add_dependency(%q<faraday_middleware>, ["~> 0.6.3"])
    s.add_dependency(%q<rash>,            ["~> 0.3.0"])
    s.add_dependency(%q<yajl-ruby>,       ["~> 0.8.2"])
    s.add_dependency(%q<rspec>,           ["~> 2.5.0"])
    s.add_dependency(%q<rcov>,            ["~> 0.9.9"])
    s.add_dependency(%q<fakeweb>,         ["~> 1.3.0"])
    s.add_dependency(%q<fakeweb-matcher>, ["~> 1.2.2"])
    s.add_dependency(%q<delayed_job>,     ["~> 2.1.4"])
  end
end

