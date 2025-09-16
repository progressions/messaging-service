module Api
  module V1
    class MessagesController < ApplicationController
    def sms
      m = create_message_for(kind: sms_params[:type] || "sms", attrs: sms_params, direction: "outbound")
      render json: m, serializer: ::MessageSerializer, status: :accepted
    end

    def email
      m = create_message_for(kind: "email", attrs: email_params, direction: "outbound")
      render json: m, serializer: ::MessageSerializer, status: :accepted
    end

    private

    def create_message_for(kind:, attrs:, direction:)
      from = attrs[:from]
      to = attrs[:to]
      conv = Conversation.find_or_create_by_participants(from, to)
      sent_at = parse_time(attrs[:timestamp])
      # If attachments param exists but isn't an array, raise a validation error (422)
      if params.key?(:attachments) && !params[:attachments].nil? && !params[:attachments].is_a?(Array)
        invalid = Message.new
        invalid.errors.add(:attachments, 'must be an array of strings')
        raise ActiveRecord::RecordInvalid, invalid
      end
      attachments = attrs[:attachments].presence || []

      provider_id = attrs[:messaging_provider_id] || attrs[:xillio_id]

      msg = conv.messages.create!(
        kind: kind,
        direction: direction,
        provider_message_id: provider_id,
        from_address: from,
        to_address: to,
        body: attrs[:body],
        attachments: attachments,
        sent_at: sent_at,
        status: 'queued'
      )

      conv.update!(last_message_at: msg.sent_at || msg.created_at)
      # Queue async send for outbound messages
      SendMessageJob.perform_later(msg.id) if direction == 'outbound'
      msg
    end

    def parse_time(val)
      return nil if val.blank?
      Time.parse(val)
    rescue
      nil
    end

    def sms_params
      params.permit(:from, :to, :type, :body, :timestamp, attachments: [])
    end

    def email_params
      params.permit(:from, :to, :body, :timestamp, :xillio_id, attachments: [])
    end

    # Presentation handled by ActiveModelSerializers
    end
  end
end
