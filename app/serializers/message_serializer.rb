class MessageSerializer < ActiveModel::Serializer
  attributes :id, :conversation_id, :kind, :direction, :status, :from, :to, :body, :attachments, :sent_at

  def from
    object.from_address
  end

  def to
    object.to_address
  end

  def attachments
    object.attachments || []
  end
end
