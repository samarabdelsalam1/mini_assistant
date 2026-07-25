require "test_helper"

class Assistant::ChatServiceTest < ActiveSupport::TestCase
  test "returns the assistant response when no tool calls are needed" do
    original_api_key = ENV["LLM_API_KEY"]
    original_model = ENV["LLM_MODEL"]
    original_base_url = ENV["LLM_BASE_URL"]

    ENV["LLM_API_KEY"] = "test-key"
    ENV["LLM_MODEL"] = "gpt-4o-mini"
    ENV["LLM_BASE_URL"] = "https://example.com"

    assistant = Object.new
    assistant.define_singleton_method(:add_message) { |role:, content:| }
    assistant.define_singleton_method(:run) { |auto_tool_execution:| }
    assistant.define_singleton_method(:messages) do
      [Struct.new(:content).new("Hello from the assistant")]
    end

    Langchain::LLM::OpenAI.singleton_class.class_eval do
      alias_method :original_new, :new
      define_method(:new) { |**_args| Object.new }
    end

    Langchain::Assistant.singleton_class.class_eval do
      alias_method :original_new, :new
      define_method(:new) { |**_args| assistant }
    end

    assert_equal "Hello from the assistant", Assistant::ChatService.call(prompt: "Hello")
  ensure
    ENV["LLM_API_KEY"] = original_api_key
    ENV["LLM_MODEL"] = original_model
    ENV["LLM_BASE_URL"] = original_base_url

    Langchain::LLM::OpenAI.singleton_class.class_eval do
      remove_method :new
      alias_method :new, :original_new
      remove_method :original_new
    end

    Langchain::Assistant.singleton_class.class_eval do
      remove_method :new
      alias_method :new, :original_new
      remove_method :original_new
    end
  end
end
