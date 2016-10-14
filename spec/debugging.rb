if RUBY_PLATFORM != "java" && RUBY_VERSION >= "2"
  begin
    require 'byebug' rescue nil
    require 'pry' rescue nil
    puts "=> Debugging tools loaded."
  rescue LoadError
    puts "=> Debugging tools not available. `bundle --with optional` if you need them."
  end
end

def show(args)
  puts "\e[1;34m#{args}\e[0m"
end