class SendMessageJob < ApplicationJob
  queue_as :default

  retry_on Providers::TransientError, wait: :exponentially_longer, attempts: 5

  def perform(message_id)
    message = Message.find(message_id)
    return if message.sent?

    client = Providers.for_kind(message.kind)
    result = client.send_message(message)

    message.update!(
      status: :sent,
      provider_message_id: result.provider_message_id,
      last_attempt_at: Time.current
    )
  rescue Providers::PermanentError => e
    message.update!(status: :failed, error_code: e.code.to_s, error_message: e.message, last_attempt_at: Time.current)
    raise e
  rescue Providers::TransientError => e
    message.update!(status: :failed, error_code: e.code.to_s, error_message: e.message, last_attempt_at: Time.current, retry_count: message.retry_count + 1)
    raise e
  end
end
