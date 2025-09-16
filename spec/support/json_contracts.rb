ISO8601_REGEX = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z\z/

module JsonContracts
  def expect_message_json(data, kind:, direction:, from:, to:, status: 'queued', body: nil, attachments: [])
    expect(data).to include(
      'id' => a_kind_of(Integer),
      'conversation_id' => a_kind_of(Integer),
      'kind' => kind,
      'direction' => direction,
      'status' => status,
      'from' => from,
      'to' => to,
      'body' => body,
      'attachments' => attachments
    )
    # sent_at can be nil or ISO8601 string
    val = data['sent_at']
    expect(val).to be_nil.or match(ISO8601_REGEX)
  end

  def expect_conversation_json(data)
    expect(data).to include(
      'id' => a_kind_of(Integer),
      'participants' => a_kind_of(Array),
      'last_message_at' => (be_nil.or match(ISO8601_REGEX))
    )
    expect(data['participants'].length).to eq(2)
  end
end

