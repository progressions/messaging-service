class Message < ApplicationRecord
  belongs_to :conversation

  enum :direction, { outbound: "outbound", inbound: "inbound" }
  enum :status, { queued: "queued", sent: "sent", failed: "failed" }

  KINDS = %w[sms mms email].freeze

  validates :from_address, :to_address, :kind, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :direction, inclusion: { in: directions.keys }
  validate :attachments_must_be_array_of_strings

  private

  def attachments_must_be_array_of_strings
    return if attachments.nil?
    unless attachments.is_a?(Array) && attachments.all? { |a| a.is_a?(String) }
      errors.add(:attachments, "must be an array of strings")
    end
  end
end
