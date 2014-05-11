appraise 'rails-2' do
  gem 'rails',   '~> 2.3.18'
  gem 'faraday', '~> 0.8.0'
end if RUBY_VERSION.to_f <= 1.8

appraise 'rails-3' do
  gem 'rails',   '~> 3.2.18'
  gem 'faraday', '~> 0.8.0'
end

appraise 'rails-4' do
  gem 'rails',   '~> 4.0.5'
  gem 'faraday', '~> 0.9.0'
end unless RUBY_VERSION.to_f <= 1.8
