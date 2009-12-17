Gem::Specification.new do |s|
  s.name = "jslint_on_rails"
  s.version = "1.0.0"
  s.summary = "JSLint JavaScript checker wrapped in a Ruby gem for easier use"
  s.homepage = "http://github.com/psionides/jslint_on_rails"

  s.author = "Jakub Suder"
  s.email = "jakub.suder@gmail.com"

  s.requirements = ['Java JRE (5.0 or later)']
  s.files = ['MIT-LICENSE', 'README.markdown'] + Dir['config/*'] + Dir['lib/**/*.rb'] + Dir['vendor/*']
end
