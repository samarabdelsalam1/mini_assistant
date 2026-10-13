# app/controllers/concerns/error_handling.rb
module ErrorHandling
  extend ActiveSupport::Concern

  included do
    # Order matters: Rails checks handlers from the bottom up,
    # so declare the generic one first and the specific ones after it.
    rescue_from Assistant::Errors::Base do |e|
      render_error(e.message, :bad_gateway)
    end

    rescue_from Assistant::Errors::InvalidPrompt do |e|
      render_error(e.message, :unprocessable_entity)
    end
  end

  private

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end