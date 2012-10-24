Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'boil'
  s.version = '0.1'
  s.summary = 'Escape from boilerplate code hell.'
  s.description = 'Escape from boilerplate code hell. This version supports automatic building of composed objects.'

  s.author = 'Martin Bilski'
  s.email = 'gyamtso@gmail.com'
  s.homepage = 'https://github.com/bilus/compser'

  s.add_dependency('active_support')
  s.files = Dir['README.md', 'MIT-LICENSE', 'lib/**/*', 'spec/**/*']
  s.has_rdoc = false

  s.require_path = 'lib'
end