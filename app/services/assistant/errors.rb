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
    
    class AssistantFailed < Base
      def initialize(msg = "Sorry, I couldn't complete that request. Please try rephrasing your question.")
        super
      end
    end

  end
end