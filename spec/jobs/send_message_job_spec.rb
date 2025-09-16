require 'rails_helper'

RSpec.describe SendMessageJob, type: :job do
  let(:conversation) { Conversation.find_or_create_by_participants('+1', '+2') }

  it 'marks message as sent on success and sets provider_message_id' do
    msg = conversation.messages.create!(kind: 'sms', direction: 'outbound', from_address: '+1', to_address: '+2', body: 'hi', status: 'queued')
    client = double('client', send_message: Providers::Result.new('prov-123'))
    allow(Providers).to receive(:for_kind).with('sms').and_return(client)

    SendMessageJob.new.perform(msg.id)

    msg.reload
    expect(msg.status).to eq('sent')
    expect(msg.provider_message_id).to eq('prov-123')
    expect(msg.last_attempt_at).to be_within(2.seconds).of(Time.current)
  end

  it 'increments retry_count and sets failed on transient error' do
    msg = conversation.messages.create!(kind: 'sms', direction: 'outbound', from_address: '+1', to_address: '+2', body: 'hi', status: 'queued')
    client = double('client')
    allow(client).to receive(:send_message).and_raise(Providers::TransientError.new('rate limit', code: 429))
    allow(Providers).to receive(:for_kind).and_return(client)

    expect { SendMessageJob.new.perform(msg.id) }.to raise_error(Providers::TransientError)
    msg.reload
    expect(msg.status).to eq('failed')
    expect(msg.retry_count).to eq(1)
    expect(msg.error_code).to eq('429')
  end

  it 'marks failed on permanent error without retry' do
    msg = conversation.messages.create!(kind: 'sms', direction: 'outbound', from_address: '+1', to_address: '+2', body: 'hi', status: 'queued')
    client = double('client')
    allow(client).to receive(:send_message).and_raise(Providers::PermanentError.new('bad request', code: 400))
    allow(Providers).to receive(:for_kind).and_return(client)

    expect { SendMessageJob.new.perform(msg.id) }.to raise_error(Providers::PermanentError)
    msg.reload
    expect(msg.status).to eq('failed')
    expect(msg.retry_count).to eq(0)
    expect(msg.error_code).to eq('400')
  end
end
