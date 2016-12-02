module Cassie::Schema
 class StructureLoader
   attr_reader :source_path


  def initialize(opts={})
    @source_path = opts[:source_path] || default_source_path
  end

  def load
    args = ["-f", source_path]
    runner = Cassie::Support::CommandRunner.new("cqlsh", args)

    runner.run
    raise runner.failure_message unless runner.success?
  end

  protected

  def default_source_path
    Cassie.paths[:schema_structure]
  end
 end
end