class AssistantController < ApplicationController
  def chat
    answer = Assistant::ChatService.call(prompt: params[:prompt])

    render json: { answer: answer }
  end
end