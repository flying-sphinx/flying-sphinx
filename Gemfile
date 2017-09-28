source 'https://rubygems.org'

gemspec

gem 'activesupport', '< 4.0.0' if RUBY_VERSION.to_f <= 1.8
gem 'riddle',        '< 2.0.0' if RUBY_VERSION.to_f <= 1.8

if RUBY_VERSION.to_f <= 1.8
  gem "public_suffix", "< 1.4.0"
elsif RUBY_VERSION.to_f <= 1.9
  gem "public_suffix", "< 1.5.0"
elsif RUBY_VERSION.to_f <= 2.0
  gem "public_suffix", "< 1.5.0"
else
  gem "public_suffix"
end

gem 'appraisal',     '~> 1.0.0',
  :git    => 'git://github.com/thoughtbot/appraisal',
  :branch => 'master',
  :ref    => 'bd6eef4b6a'
