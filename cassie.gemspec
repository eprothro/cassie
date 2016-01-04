Gem::Specification.new do |s|
  s.name        = 'cassie'
  s.version     = '0.0.1.a1'
  s.summary     = "Apache Cassandra application support"
  s.description = <<-EOS.strip.gsub(/\s+/, ' ')
    Cassie adds support for database configration, versioned migrations,
    efficient session management, and query classes. This allows an application
    to use the functionality provided by the official `cassandra-driver` in a
    lightweight and easy to use package.
  EOS
  s.authors     = ["Evan Prothro"]
  s.email       = 'evan.prothro@gmail.com'
  s.files      += Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/eprothro/cassie'
  s.license     = 'MIT'

  s.add_runtime_dependency 'cassie-queries', '~> 0.0.1'

  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'benchmark-ips'
end