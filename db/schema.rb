# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_09_15_002000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversations", force: :cascade do |t|
    t.string "participant_a", null: false
    t.string "participant_b", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_message_at"], name: "index_conversations_on_last_message_at"
    t.index ["participant_a", "participant_b"], name: "idx_conversations_participants", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "kind", null: false
    t.string "direction", null: false
    t.string "provider_message_id"
    t.string "from_address", null: false
    t.string "to_address", null: false
    t.text "body"
    t.jsonb "attachments", default: []
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "queued", null: false
    t.string "error_code"
    t.text "error_message"
    t.integer "retry_count", default: 0, null: false
    t.datetime "last_attempt_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["direction"], name: "index_messages_on_direction"
    t.index ["kind"], name: "index_messages_on_kind"
    t.index ["provider_message_id"], name: "idx_messages_inbound_provider_id_unique", unique: true, where: "(((direction)::text = 'inbound'::text) AND (provider_message_id IS NOT NULL))"
    t.index ["provider_message_id"], name: "index_messages_on_provider_message_id"
    t.index ["sent_at"], name: "index_messages_on_sent_at"
    t.index ["status"], name: "index_messages_on_status"
  end

  add_foreign_key "messages", "conversations"
end
