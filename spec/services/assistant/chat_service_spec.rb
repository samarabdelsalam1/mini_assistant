require 'rails_helper'

RSpec.describe Assistant::ChatService do
  let(:mock_llm) { instance_double("Langchain::LLM::OpenAI") }
  let(:mock_assistant) { instance_double("Langchain::Assistant") }
  
  # A dummy message that mimics what langchainrb returns after running
  let(:mock_response_message) { double("Message", content: "I have Peanut Butter and Biscoff.") }

  before do
    # Stub the Langchain initialization and execution to prevent real API calls
    allow(Langchain::Assistant).to receive(:new).and_return(mock_assistant)
    allow(mock_assistant).to receive(:add_message)
    allow(mock_assistant).to receive(:run)
    allow(mock_assistant).to receive(:messages).and_return([mock_response_message])
    allow(mock_assistant).to receive(:state).and_return(:completed)
  end

  describe '#call' do
    context 'when starting a new conversation (no ID provided)' do
      it 'creates a new Conversation record in the database' do
        expect {
          described_class.call(prompt: "What do you have?", llm: mock_llm)
        }.to change(Conversation, :count).by(1)
      end

      it 'returns the full conversation messages array and the new conversation_id' do
        result = described_class.call(prompt: "What do you have?", llm: mock_llm)

        # UPDATED: We now expect the full history array instead of just the text string
        expect(result[:answer]).to eq([
          { "role" => "user", "content" => "What do you have?" },
          { "role" => "assistant", "content" => "I have Peanut Butter and Biscoff." }
        ])
        expect(result[:conversation_id]).to eq(Conversation.last.id)
      end

      it 'saves the user prompt and assistant answer to the JSONB messages array' do
        described_class.call(prompt: "What do you have?", llm: mock_llm)
        
        conversation = Conversation.last
        expect(conversation.messages).to eq([
          { "role" => "user", "content" => "What do you have?" },
          { "role" => "assistant", "content" => "I have Peanut Butter and Biscoff." }
        ])
      end
    end

    context 'when continuing an existing conversation' do
      let!(:existing_conversation) do
        Conversation.create!(
          messages: [
            { "role" => "user", "content" => "Hi I am Samar" },
            { "role" => "assistant", "content" => "Hello Samar! How can I help?" }
          ]
        )
      end

      it 'loads historical messages into the LLM context window' do
        described_class.call(
          prompt: "What was my name?", 
          conversation_id: existing_conversation.id, 
          llm: mock_llm
        )

        expect(mock_assistant).to have_received(:add_message).with(role: "user", content: "Hi I am Samar").ordered
        expect(mock_assistant).to have_received(:add_message).with(role: "assistant", content: "Hello Samar! How can I help?").ordered
        expect(mock_assistant).to have_received(:add_message).with(role: "user", content: "What was my name?").ordered
      end

      it 'appends the new interaction and returns the full updated message array' do
        result = described_class.call(
          prompt: "What was my name?", 
          conversation_id: existing_conversation.id, 
          llm: mock_llm
        )

        # Verify the database was updated
        existing_conversation.reload
        expect(existing_conversation.messages.length).to eq(4)
        
        # Verify the return value includes all 4 messages
        expect(result[:answer].length).to eq(4)
        expect(result[:answer].last["content"]).to eq("I have Peanut Butter and Biscoff.")
      end
    end

    context 'when the prompt is invalid' do
      it 'raises InvalidPrompt if empty' do
        expect {
          described_class.call(prompt: "", llm: mock_llm)
        }.to raise_error(Assistant::Errors::InvalidPrompt, "Please type a question.")
      end
    end

    context 'when the external AI API fails' do
      it 'translates Faraday::TimeoutError into an UpstreamTimeout error' do
        allow(mock_assistant).to receive(:run).and_raise(Faraday::TimeoutError)

        expect {
          described_class.call(prompt: "Hello", llm: mock_llm)
        }.to raise_error(Assistant::Errors::UpstreamTimeout)
      end
    end
  end
end