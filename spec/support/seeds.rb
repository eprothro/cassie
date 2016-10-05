# http://guides.rubyonrails.org/autoloading_and_reloading_constants.html#require-dependency
# we must require dependency because we don't
# want to have have namespacing that matches dir structure
# and as a result, autoloading won't work by default
Dir.glob("#{__dir__}/seeds/**/*.rb").each do |file|
  require file
end