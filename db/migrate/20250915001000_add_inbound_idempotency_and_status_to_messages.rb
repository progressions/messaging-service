class AddInboundIdempotencyAndStatusToMessages < ActiveRecord::Migration[7.1]
  def up
    add_column :messages, :status, :string, null: false, default: 'queued'
    add_column :messages, :error_code, :string
    add_column :messages, :error_message, :text
    add_column :messages, :retry_count, :integer, null: false, default: 0
    add_column :messages, :last_attempt_at, :datetime

    add_index :messages, :status

    # Clean up any existing duplicates before adding unique index
    execute <<~SQL
      DELETE FROM messages m1
      USING messages m2
      WHERE m1.id > m2.id
        AND m1.direction = 'inbound'
        AND m2.direction = 'inbound'
        AND m1.provider_message_id IS NOT NULL
        AND m1.provider_message_id = m2.provider_message_id;
    SQL

    add_index :messages, :provider_message_id,
              unique: true,
              name: 'idx_messages_inbound_provider_id_unique',
              where: "direction = 'inbound' AND provider_message_id IS NOT NULL"
  end

  def down
    remove_index :messages, name: 'idx_messages_inbound_provider_id_unique', if_exists: true
    remove_index :messages, :status, if_exists: true
    remove_column :messages, :last_attempt_at, if_exists: true
    remove_column :messages, :retry_count, if_exists: true
    remove_column :messages, :error_message, if_exists: true
    remove_column :messages, :error_code, if_exists: true
    remove_column :messages, :status, if_exists: true
  end
end
