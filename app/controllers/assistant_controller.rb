class AssistantController < ApplicationController
  def chat
    result = Assistant::ChatService.call(
      prompt: params[:prompt],
      conversation_id: params[:conversation_id]
    )

    render json: result
  end
end