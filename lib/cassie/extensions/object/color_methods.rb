module Cassie::Extensions
  module Object
    module ColorMethods
      def white(message)
        "\e[1;37m#{message}\e[0m"
      end

      def red(message)
        "\e[1;31m#{message}\e[0m"
      end

      def green(message)
        "\e[1;32m#{message}\e[0m"
      end
    end
  end
end

class Object
  include Cassie::Extensions::Object::ColorMethods
end