module Assistant
  class ChatService
    def self.call(prompt:)
      new(prompt: prompt).call
    end

    def initialize(prompt:)
      @prompt = prompt
    end

    def call
      messages = build_messages
      client = OpenAI::Client.new
      max_iterations = 5
      iteration = 0

      loop do
        iteration += 1
        break if iteration > max_iterations

        response = client.chat(
          parameters: {
            model: ENV.fetch("OPENAI_MODEL", "llama3.2:1b"),
            messages: messages,
            tools: shop_tools
          }
        )

        assistant_message = response.dig("choices", 0, "message")
        messages << assistant_message

        if assistant_message["tool_calls"].present?
          assistant_message["tool_calls"].each do |tool_call|
            function_name = tool_call.dig("function", "name")
            arguments = JSON.parse(tool_call.dig("function", "arguments"))
            result = execute_local_tool(function_name, arguments)

            messages << {
              role: "tool",
              tool_call_id: tool_call["id"],
              content: result.to_json
            }
          end
        else
          return assistant_message["content"]
        end
      end
    end

    private

    def build_messages
      [
        { role: "system", content: "You are the Cozy Cookies assistant. Use your tools to answer customer questions." },
        { role: "user", content: @prompt }
      ]
    end

    def shop_tools
      [
        {
          type: "function",
          function: {
            name: "check_cookie_price",
            deescription: "Get the current price for a specific cookie flavor.",
            parameters: {
              type: "object",
              properties: {
                flavor: { type: "string", description: "e.g., peanut_butter, chocolate, biscoff" }
              },
              required: ["flavor"]
            }
          }
        }
      ]
    end

    def execute_local_tool(name, args)
      if name == "check_cookie_price"
        flavor = args["flavor"]

        case flavor
        when "peanut_butter"
          { price: "160 LE", status: "in_stock" }
        when "biscoff"
          { price: "180 LE", status: "in_stock" }
        else
          { error: "Flavor not found in our menu." }
        end
      else
        { error: "Unknown tool" }
      end
    end
  end
end
