source 'https://rubygems.org'

gemspec

if RUBY_VERSION.to_f <= 1.8
  gem "public_suffix", "< 1.4.0"
  gem "nokogiri",      "< 1.6.0"
  gem "activesupport", "< 4.0.0"
elsif RUBY_VERSION.to_f <= 1.9
  gem "public_suffix", "< 1.5.0"
  gem "mime-types",    "< 3.0"
  gem "nokogiri",      "< 1.7.0"
elsif RUBY_VERSION.to_f <= 2.0
  gem "public_suffix", "< 1.5.0"
  gem "nokogiri",      "< 1.7.0"
end

gem 'appraisal',     '~> 1.0.0',
  :git    => 'https://github.com/thoughtbot/appraisal',
  :branch => 'master',
  :ref    => 'bd6eef4b6a'
