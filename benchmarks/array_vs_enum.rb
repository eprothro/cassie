require 'benchmark/ips'
require 'cassie'
require 'memory_profiler'

items = 100
@rows = Array.new(items){{id: Cassandra::Uuid::Generator.new.uuid, text: Array(rand(10000)){'a'}.join, number: 1000}}

@deserializer = Proc.new do |row|
  Struct.new(*row.keys.map(&:to_sym)).new(*row.values)
end

def each_record
  return enum_for(:each_record) unless block_given?

  @rows.each do |row|
    yield @deserializer.call(row)
  end
end

def records
  @rows.map{ |row| @deserializer.call(row) }
end

puts "**** enum"
# Total allocated: 689392 bytes (4205 objects)
# Total retained:  312 bytes (4 objects)
report = MemoryProfiler.report do
  3.times do
    each_record.each do |r|
      r.id
    end
  end
end

report.pretty_print

puts "**** array"
# Total allocated: 691320 bytes (4203 objects)
# Total retained:  0 bytes (0 objects)
report = MemoryProfiler.report do
  3.times do
    records.each do |r|
      r.id
    end
  end
end

report.pretty_print

Benchmark.ips do |b|
  b.report("enum-results") do
    each_record.each do |r|
      r.id
    end
  end

  b.report("array-results") do
    records.each do |r|
      r.id
    end
  end

  b.compare!
end