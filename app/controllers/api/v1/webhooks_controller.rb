module Api
  module V1
    class WebhooksController < ApplicationController
    def sms
      m = create_message_for(kind: params[:type] || "sms", attrs: webhook_sms_params, direction: "inbound")
      payload = ActiveModelSerializers::SerializableResource.new(m, serializer: ::MessageSerializer).as_json
      render json: { received: true, message: payload }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def email
      m = create_message_for(kind: "email", attrs: webhook_email_params, direction: "inbound")
      payload = ActiveModelSerializers::SerializableResource.new(m, serializer: ::MessageSerializer).as_json
      render json: { received: true, message: payload }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def create_message_for(kind:, attrs:, direction:)
      from = attrs[:from]
      to = attrs[:to]
      conv = Conversation.find_or_create_by_participants(from, to)
      sent_at = parse_time(attrs[:timestamp])
      attachments = attrs[:attachments].presence || []

      provider_id = attrs[:messaging_provider_id] || attrs[:xillio_id]

      # Idempotent for inbound events with provider id
      if direction == 'inbound' && provider_id.present?
        existing = Message.find_by(provider_message_id: provider_id, direction: 'inbound')
        return existing if existing
      end

      msg = conv.messages.create!(
        kind: kind,
        direction: direction,
        provider_message_id: provider_id,
        from_address: from,
        to_address: to,
        body: attrs[:body],
        attachments: attachments,
        sent_at: sent_at
      )
      conv.update!(last_message_at: msg.sent_at || msg.created_at)
      msg
    end

    def parse_time(val)
      return nil if val.blank?
      Time.parse(val)
    rescue
      nil
    end

    def webhook_sms_params
      params.permit(:from, :to, :type, :messaging_provider_id, :body, :timestamp, attachments: [])
    end

    def webhook_email_params
      params.permit(:from, :to, :xillio_id, :body, :timestamp, attachments: [])
    end
    end
  end
end
