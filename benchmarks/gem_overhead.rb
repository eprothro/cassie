# require 'ruby-prof'

# # RubyProf.measure_mode = RubyProf::WALL_TIME
# # RubyProf.measure_mode = RubyProf::PROCESS_TIME
# # RubyProf.measure_mode = RubyProf::CPU_TIME
# # RubyProf.measure_mode = RubyProf::ALLOCATIONS
# RubyProf.measure_mode = RubyProf::MEMORY
# # RubyProf.measure_mode = RubyProf::GC_TIME
# # RubyProf.measure_mode = RubyProf::GC_RUNS

# result = RubyProf.profile do
#   require 'cassie'
# end

# # printer = RubyProf::GraphPrinter.new(result)
# # printer.print(STDOUT, min_percent: 2)

# printer = RubyProf::GraphHtmlPrinter.new(result)
# path = File.expand_path("../reports/#{File.basename(__FILE__)}.html", __FILE__)
# File.open(path, 'w') { |file| printer.print(file, min_percent: 0) }
# Kernel.system("open", path)

require 'memory_profiler'

report = MemoryProfiler.report do
  require './lib/cassie'
end

report.pretty_print

# 1 meg for ActiveSupport
# 4 megs for Cassandra driver