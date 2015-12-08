Gem::Specification.new do |s|
  s.name        = 'cassie-queries'
  s.version     = '0.0.1.pre'
  s.date        = '2015-12-09'
  s.summary     = "Apache Cassandra query management"
  s.description = <<-EOS.strip.gsub(/\s+/, ' ')
    `cassie-queries` is a lightweight interface adapter allowing
    easy use of the functionality provided by the `cassandra-driver`.
  EOS
  s.authors     = ["Evan Prothro"]
  s.email       = 'evan.prothro@gmail.com'
  s.files      += Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/eprothro/cassie-queries'
  s.license     = 'MIT'

  s.add_runtime_dependency 'cassandra-driver', '~> 2.0'
  s.add_runtime_dependency 'activesupport', '~> 4.2'

  s.add_development_dependency 'rspec', '~> 3.4'
end