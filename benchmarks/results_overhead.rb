require 'benchmark/ips'
require './lib/cassie'
require './lib/cassie/testing'

# Run this benchmark to print a comparison
# of vanilla use of cassandra-driver
# and using the cassandra library
#
#    $ ruby benchmarks/overhead.rb
#
#    Comparison:
#     cassie-query-generation:   753594.1 i/s
#     baseline-query-generation: 752032.5 i/s - 1.00x slower
#
Benchmark.ips do |b|

  results = Array.new(1000){{id: Cassandra::Uuid::Generator.new.uuid, text: Array(rand(10000)){'a'}.join, number: 1000}}
  session = Cassie::Testing::Fake::Session.new
  session.rows = results

  statement = Cassandra::Statements::Simple.new('test', nil)

  b.report("baseline-query-results") do
    rows = session.rows.count
  end

  b.report("cassie-query-generation") do
    rows = Cassie::Statements::Results::QueryResult.new(session.execute(statement)).rows
  end

  b.compare!
end