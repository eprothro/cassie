require "erb"

module Cassie
  module Configuration
    class Generator
      include ERB::Util
      attr_accessor :app_name,
                    :template_path,
                    :destination_path

      def initialize(opts={})
        @app_name = opts.fetch(:app_name, default_app_name)
        @template_path = opts.fetch(:template_path, default_template_path)
        @destination_path = opts.fetch(:destination_path, default_destination_path)
      end

      def render
        ERB.new(template).result(binding)
      end

      def save
        File.open(destination_path, "w+") do |f|
          f.write(render)
        end
      end

      protected

      def template
        File.new(template_path).read
      end

      def default_app_name
        "my_app"
      end

      def default_template_path
        File.expand_path("../templates/cassandra.yml", __FILE__)
      end

      def default_destination_path
        Dir.mkdir(config_dir) unless File.directory?(config_dir)
        File.join(root, "config/cassandra.yml")
      end

      def config_dir
        File.join(root, "config")
      end

      def root
        Dir.pwd
      end
    end
  end
end