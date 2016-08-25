module Cassie::Queries::Instrumentation
  module Loading

    protected

    def build_resources(rows)
      instrumenter.instrument("cassie.building_resources") do |payload|
        payload[:count] = rows.count if rows.respond_to?(:count)
        super
      end
    end
  end
end


