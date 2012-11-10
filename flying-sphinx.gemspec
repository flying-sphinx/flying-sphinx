# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'flying_sphinx/version'

Gem::Specification.new do |s|
  s.name        = 'flying-sphinx'
  s.version     = FlyingSphinx::Version
  s.authors     = ['Pat Allan']
  s.email       = 'pat@freelancing-gods.com'
  s.summary     = 'Sphinx in the Cloud'
  s.description = 'Hooks Thinking Sphinx into the Flying Sphinx service'
  s.homepage    = 'https://flying-sphinx.com'

  s.extra_rdoc_files = ['README.textile']
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
  s.executables   = ['flying-sphinx']

  s.add_runtime_dependency 'thinking-sphinx',    ['>= 3.0.0pre']
  s.add_runtime_dependency 'riddle',             ['>= 1.5.0']
  s.add_runtime_dependency 'multi_json',         ['>= 1.0.1']
  s.add_runtime_dependency 'faraday_middleware', ['~> 0.7']
  s.add_runtime_dependency 'rash',               ['~> 0.3.0']

  s.add_development_dependency 'rake',            ['~> 0.9.2']
  s.add_development_dependency 'rspec',           ['~> 2.11']
  s.add_development_dependency 'rspec-fire',      ['~> 1.1.0']
  s.add_development_dependency 'yajl-ruby',       ['~> 0.8.2']
  s.add_development_dependency 'fakeweb',         ['~> 1.3.0']
  s.add_development_dependency 'fakeweb-matcher', ['~> 1.2.2']
  s.add_development_dependency 'delayed_job',     ['~> 2.1.4']
  s.add_development_dependency 'mysql2',          ['>= 0.3.12b4']

  s.post_install_message = <<-MESSAGE
If you're upgrading, you should rebuild your Sphinx setup when deploying:

  $ heroku rake fs:rebuild
MESSAGE
end
