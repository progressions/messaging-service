class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  private

  def render_record_invalid(exception)
    record = exception.record
    errors = record.errors.map { |attr, msg| { field: attr.to_s, message: msg } }
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
