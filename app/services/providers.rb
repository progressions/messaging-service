require 'securerandom'

module Providers
  class Result < Struct.new(:provider_message_id); end
  class Error < StandardError
    attr_reader :code
    def initialize(message = nil, code: nil)
      @code = code
      super(message)
    end
  end
  class TransientError < Error; end # e.g., 429, 5xx
  class PermanentError < Error; end # e.g., 4xx validation

  def self.for_kind(kind)
    case kind
    when 'sms', 'mms' then SmsClient.new
    when 'email' then EmailClient.new
    else raise Providers::PermanentError.new('invalid kind', code: :invalid_kind)
    end
  end

  class SmsClient
    def send_message(message)
      # Stub send; integrate with real provider later
      Result.new("sms-#{SecureRandom.uuid}")
    end
  end

  class EmailClient
    def send_message(message)
      Result.new("email-#{SecureRandom.uuid}")
    end
  end
end
