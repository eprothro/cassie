# Revert patch made in break_io_popen.rb
# to allow system commands to be run for
# this spec run
class IO
  def self.allow_popen?
    true
  end
end