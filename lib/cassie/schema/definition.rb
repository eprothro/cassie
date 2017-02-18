module Cassie::Schema

  # Extend Defintion to get the +define+ class method
  # used to define schema for a cassandra cluster
  module Definition
    require_relative 'definition/dsl'

    def define(&block)
      raise "block required to define schema." unless block_given?

      DSL.instance_eval(&block)
    end
  end
end