require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe "messages" do
    it "defaults to an empty array" do
      expect(described_class.new.messages).to eq([])
    end

    it "persists and reloads the conversation history" do
      messages = [
        { "role" => "user", "content" => "Hello" },
        { "role" => "assistant", "content" => "Hi there!" }
      ]

      conversation = described_class.create!(messages: messages)

      expect(described_class.find(conversation.id).messages).to eq(messages)
    end
  end
end
