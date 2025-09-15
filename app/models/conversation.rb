class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :participant_a, :participant_b, presence: true

  def self.find_or_create_by_participants(from, to)
    a, b = Conversation.normalize_pair(from, to)
    find_or_create_by(participant_a: a, participant_b: b)
  end

  def self.normalize_address(addr)
    return "" if addr.nil?
    addr.to_s.strip.downcase
  end

  def self.normalize_pair(from, to)
    a = normalize_address(from)
    b = normalize_address(to)
    [a, b].sort
  end
end

