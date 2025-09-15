class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.string :participant_a, null: false
      t.string :participant_b, null: false
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :conversations, [:participant_a, :participant_b], unique: true, name: "idx_conversations_participants"
  end
end

