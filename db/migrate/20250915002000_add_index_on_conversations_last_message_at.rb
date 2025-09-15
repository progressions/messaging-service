class AddIndexOnConversationsLastMessageAt < ActiveRecord::Migration[7.1]
  def change
    add_index :conversations, :last_message_at
  end
end

