class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  private

  def render_record_invalid(exception)
    record = exception.record
    errors = record.errors.map do |error|
      # Rails 7/8: error is ActiveModel::Error
      {
        field: error.attribute.to_s,
        message: (error.respond_to?(:full_message) ? error.full_message : error.message)
      }
    end
    render json: { errors: errors }, status: :unprocessable_content
  end
end
