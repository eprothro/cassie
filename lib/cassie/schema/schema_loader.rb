module Cassie::Schema
 class SchemaLoader
   attr_reader :source_path


  def initialize(opts={})
    @source_path = opts[:source_path] || default_source_path
  end

  def load
    Kernel.load File.absolute_path(source_path)
  end

  protected

  def default_source_path
    Cassie::Schema.paths[:schema_file]
  end
 end
end