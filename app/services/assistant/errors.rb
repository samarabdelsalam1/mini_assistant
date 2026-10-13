# app/services/assistant/errors.rb
module Assistant
  module Errors
    class Base < StandardError; end

    class InvalidPrompt < Base; end

    class UpstreamTimeout < Base
      def initialize(msg = "The assistant is taking too long to respond. Please try again.")
        super
      end
    end

    class ServiceUnavailable < Base
      def initialize(msg = "The assistant is temporarily unavailable. Please try again in a moment.")
        super
      end
    end

  end
end