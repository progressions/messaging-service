class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :kind, null: false # sms, mms, email
      t.string :direction, null: false # inbound, outbound
      t.string :provider_message_id
      t.string :from_address, null: false
      t.string :to_address, null: false
      t.text :body
      t.jsonb :attachments, default: []
      t.datetime :sent_at

      t.timestamps
    end

    add_index :messages, :provider_message_id
    add_index :messages, :kind
    add_index :messages, :direction
    add_index :messages, :sent_at
  end
end

