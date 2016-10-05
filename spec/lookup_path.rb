def lookup_path(object, method)
  owner = object
  _method = owner.method(method)
  chain = []

  while _method.respond_to?(:super_method)
    chain << _method
    _method = _method.super_method
  end

  puts "Method Lookup for #{object} : #{owner.method(method).name}\n"
  chain.reverse.each.with_index do |link, i|
    case i
    when 0
      puts link.inspect
      puts "    "*i + "from: #{link.source_location.join(':')}"
    when chain.length - 1
      puts "    "*i + "^ ^ ^"
      puts "    "*i + "#{link.inspect}" + "\e[1;32m <-- Entry Point\e[0m\n"
      puts "    "*i + "from: #{link.source_location.join(':')}"
    else
      puts "    "*i + "^ ^ ^"
      puts "    "*i + "#{link.inspect}"
      puts "    "*i + "from: #{link.source_location.join(':')}"
    end
  end
  nil
end