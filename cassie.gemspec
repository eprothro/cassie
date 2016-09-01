require_relative 'lib/cassie/version'

Gem::Specification.new do |s|
  s.name        = 'cassie'
  s.version     = Cassie::VERSION
  s.summary     = "Apache Cassandra application support"
  s.description = <<-EOS.strip.gsub(/\s+/, ' ')
    Cassie provides database configration, versioned migrations,
    efficient session management, and query classes. This allows applications
    to use the functionality provided by the official `cassandra-driver` through
    lightweight and easy to use interfaces.
  EOS

  s.authors     = ["Evan Prothro"]
  s.email       = 'evan.prothro@gmail.com'
  s.files      += Dir['lib/**/*.*']
  s.homepage    = 'https://github.com/eprothro/cassie'
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'

  s.add_runtime_dependency 'cassandra-driver', '~> 3.0', '>= 2.1.1'
  s.add_runtime_dependency 'activesupport', '~> 4.2'
  s.add_runtime_dependency 'terminal-table', '~> 1.4', '>= 1.4.0'

  s.executables << 'cassie'

end