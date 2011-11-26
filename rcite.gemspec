Gem::Specification.new do |s|
  s.name        = 'rcite'
  s.version     = '0.0.1'

  s.summary     = "Citation and bibliography generator."
  s.description = "RCite parses BibTeX files and generates citations as well"+
    " as bibliography entries based on styles. Its key feature is the simple"+
    " style syntax that sets it apart from BibTeX, BibLaTeX and CSL."
  s.license     = ['MIT']

  s.authors     = ["Jannis Limperg"]
  s.email       = 'jannis.limperg@arcor.de'
  s.homepage    = 'http://rubygems.org/gems/rcite'

  s.files       = Dir["lib/**/*.rb"] + Dir["bin/**/*"] + Dir["spec/**/*"]
  s.executables << 'rcite'
  
  s.add_runtime_dependency 'bibtex-ruby', '~> 2.0'
  s.add_runtime_dependency 'slop', '~> 2.1'
  s.add_runtime_dependency 'require_all', '~> 1.2'

  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'simplecov', '~> 0.5'
  s.add_development_dependency 'yard', '~> 0.7'
  s.add_development_dependency 'rake', '~> 0.9'
end
