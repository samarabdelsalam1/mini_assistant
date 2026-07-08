require "test_helper"

class Assistant::ChatServiceTest < ActiveSupport::TestCase
  test "returns the assistant response when no tool calls are needed" do
    client = Object.new

    client.define_singleton_method(:chat) do |parameters:| 
      {
        "choices" => [
          {
            "message" => {
              "content" => "Hello from the assistant",
              "tool_calls" => nil
            }
          }
        ]
      }
    end

    OpenAI::Client.singleton_class.class_eval do
      alias_method :original_new, :new
      define_method(:new) { client }
    end

    assert_equal "Hello from the assistant", Assistant::ChatService.call(prompt: "Hello")
  ensure
    OpenAI::Client.singleton_class.class_eval do
      remove_method :new
      alias_method :new, :original_new
      remove_method :original_new
    end
  end
end
