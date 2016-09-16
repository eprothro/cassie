require 'benchmark/ips'
require 'cassie'
require 'memory_profiler'

def mod
  Module.new do
    def foo
    end
  end
end

def additive_mod
  Module.new do
    def foo
      super
    end
  end
end

# ~2.27 usec execution time
@klass = Class.new
@klass.include(mod)

# ~2.38 usec execution time
# + 11 nsec
@overriding_class = Class.new
@overriding_class.include(mod)
@overriding_class.include(additive_mod)

# ~3.03 usec per
# + 760 nsec from baseline
# ~ 76 nsec per mixin + super
@overriding_class_10 = Class.new
@overriding_class_10.include(mod)
10.times { @overriding_class_10.include(additive_mod) }

# ~10.4 usec per
# + 8130 nsec from baseline
# ~ 81 nsec per mixin + super
@overriding_class_100 = Class.new
@overriding_class_100.include(mod)
100.times { @overriding_class_100.include(additive_mod) }

Benchmark.ips do |b|
  b.report("method") do
    @klass.new.foo
  end

  b.report("1 override") do
    @overriding_class.new.foo
  end

  b.report("10 overrides") do
    @overriding_class_10.new.foo
  end

  b.report("100 overrides") do
    @overriding_class_100.new.foo
  end

  b.compare!
end