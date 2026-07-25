require "langchain"

module Assistant
  class ChatService
    def self.call(prompt:)
      new(prompt: prompt).call
    end

    def initialize(prompt:)
      @prompt = prompt
    end

    def call
      assistant = Langchain::Assistant.new(
        llm: default_llm,
        tools: [CookieMenuTool.new], 
        instructions: "You are the Cozy Cookies assistant. Use your tools to answer customer questions."
      )

      assistant.add_message(role: "user", content: @prompt)
      assistant.run(auto_tool_execution: true)
      
      assistant.messages.last.content
    end

    private

    # Centralize your config here instead of an initializer

    def default_llm
      llm ||= Langchain::LLM::OpenAI.new(
        api_key: ENV.fetch("LLM_API_KEY"),
        llm_options: { uri_base: ENV.fetch("LLM_BASE_URL", nil) }.compact,
        default_options: {
          chat_model: ENV.fetch("LLM_MODEL")  
        }
      )
    end

  end
end