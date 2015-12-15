require 'benchmark/ips'
require_relative 'support/baseline_generator'
require_relative 'support/cassie_generator'

# Run this benchmark to print a comparison
# of vanilla use of cassandra-driver
# and using the cassandra-query library
#
#    $ ruby benchmarks/overhead.rb
#
#    Comparison:
#     cassie-query-generation:   753594.1 i/s
#     baseline-query-generation: 752032.5 i/s - 1.00x slower
#
Benchmark.ips do |b|
  g = BaselineGenerator.new

  b.report("baseline-query-generation") do
    g.generate
  end

  g = CassieGenerator.new

  b.report("cassie-query-generation") do
    g.generate
  end

  b.compare!
end