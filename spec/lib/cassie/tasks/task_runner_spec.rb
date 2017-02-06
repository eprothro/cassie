require 'cassie/tasks'

RSpec.describe Cassie::Tasks::TaskRunner do
  let(:klass){ Cassie::Tasks::TaskRunner }
  let(:object){ klass.new }
  let(:args){ Array(command) + params }
  let(:params){ [] }
  let(:command){ nil }

  describe "#run_command" do
    def run
      object.run_command(args)
    end
    Rake.application.tasks.each do |t|
      context "with the #{t.name} task" do
        let(:command){ t.name.sub("cassie:", "") }

        it "finds an associated command" do
          task = Rake::Task["cassie:#{command}"]
          expect(task).to receive(:invoke)
          run
        end
      end
    end

    [
      "start",
      "stop",
      "restart",
      "tail",
      "configuration:generate",
      "migrations:import",
      "migration:create",
      "migrate",
      # "migrate:reset",
      "schema:version",
      "schema:history",
      # "schema:status",
      # "schema:load",
      # "schema:drop",
      # "schema:reset",
      "schema:import",
      "structure:dump",
      "structure:load"
    ]
    .each do | cmd_string |
      context "with the #{cmd_string} command" do
        let(:command){ cmd_string }
        let(:task){ Rake::Task["cassie:#{command}"] }

        it "runs an associated task" do
          expect(task).to receive(:invoke)
          run
        end
      end
    end
  end
end