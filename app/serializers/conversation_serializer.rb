class ConversationSerializer < ActiveModel::Serializer
  attributes :id, :participants, :last_message_at

  def participants
    [object.participant_a, object.participant_b]
  end
end
