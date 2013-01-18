#encoding: utf-8
Gem::Specification.new do |s|
  s.name        = 'ghost_queries'
  s.version     = '0.1.0'
  s.date        = '2013-01-17'
  s.summary     = "a summary"
  s.description = "a description"
  s.authors     = ["Pablo Bianciotto"]
  s.email       = 'bianciottopablo@gmail.com'
  s.files       = ["Rakefile", "LICENSE", "README.md", "Gemfile", "Gemfile.lock"]
  s.files	   += Dir['lib/**/*.rb'] + Dir['test/*']
  s.homepage    = 'https://github.com/akhanubis/ghost_queries'
  s.add_runtime_dependency 'activesupport', '~> 3.2.11'
end