#encoding: utf-8
Gem::Specification.new do |s|
  s.name        = 'google_calendar_finder_v3'
  s.version     = '0.0.4'
  s.date        = '2013-01-11'
  s.summary     = "a summary"
  s.description = "a description"
  s.authors     = ["Pablo Bianciotto"]
  s.email       = 'bianciottopablo@gmail.com'
  s.files       = ["Rakefile", "LICENSE", "README.md", "Gemfile", "Gemfile.lock"]
  s.files	   += Dir['lib/**/*.rb'] + Dir['test/*']
  s.homepage    = 'https://github.com/akhanubis/google_calendar_finder_v3'
  s.add_runtime_dependency 'google-api-client', '~> 0.5.0'
  s.add_runtime_dependency 'activesupport', '~> 3.2.11'
end