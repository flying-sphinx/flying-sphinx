Jeweler::Tasks.new do |gem|
  gem.name        = "flying-sphinx"
  gem.summary     = "Sphinx in the Cloud"
  gem.description = "Hooks Thinking Sphinx into the Flying Sphinx service"
  gem.author      = "Pat Allan"
  gem.email       = "pat@freelancing-gods.com"
  gem.homepage    = "http://flying-sphinx.com"
  
  gem.files     = FileList[
    "lib/**/*.rb",
    "keys/key",
    "LICENCE",
    "README.textile",
    "VERSION"
  ]
  gem.test_files = FileList[
    "spec/**/*_spec.rb"
  ]
end
