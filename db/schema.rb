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

ActiveRecord::Schema[8.1].define(version: 2026_09_05_050727) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "badges", force: :cascade do |t|
    t.string "badge_type", default: "bronze", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_badges_on_slug", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "discussion_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["discussion_id"], name: "index_bookmarks_on_discussion_id"
    t.index ["user_id", "discussion_id"], name: "index_bookmarks_on_user_id_and_discussion_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "color_accent", default: "#6366f1", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discussions_count", default: 0, null: false
    t.string "icon", default: "folder", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_categories_on_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "discussion_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "discussion_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["discussion_id", "tag_id"], name: "index_discussion_tags_on_discussion_id_and_tag_id", unique: true
    t.index ["discussion_id"], name: "index_discussion_tags_on_discussion_id"
    t.index ["tag_id", "discussion_id"], name: "index_discussion_tags_on_tag_id_and_discussion_id"
    t.index ["tag_id"], name: "index_discussion_tags_on_tag_id"
  end

  create_table "discussions", force: :cascade do |t|
    t.bigint "accepted_reply_id"
    t.text "body", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.boolean "pinned", default: false, null: false
    t.integer "reply_count", default: 0, null: false
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "view_count", default: 0, null: false
    t.integer "vote_score", default: 0, null: false
    t.index "to_tsvector('english'::regconfig, (((COALESCE(title, ''::character varying))::text || ' '::text) || COALESCE(body, ''::text)))", name: "index_discussions_on_fts", using: :gin
    t.index ["category_id", "created_at"], name: "index_discussions_on_category_id_and_created_at"
    t.index ["category_id"], name: "index_discussions_on_category_id"
    t.index ["created_at"], name: "index_discussions_on_created_at"
    t.index ["pinned"], name: "index_discussions_on_pinned"
    t.index ["reply_count"], name: "index_discussions_on_reply_count"
    t.index ["slug"], name: "index_discussions_on_slug", unique: true
    t.index ["status"], name: "index_discussions_on_status"
    t.index ["user_id", "created_at"], name: "index_discussions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_discussions_on_user_id"
    t.index ["view_count"], name: "index_discussions_on_view_count"
    t.index ["vote_score"], name: "index_discussions_on_vote_score"
  end

  create_table "mentions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "mentionable_id", null: false
    t.string "mentionable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["mentionable_type", "mentionable_id"], name: "index_mentions_on_mentionable_type_and_mentionable_id"
    t.index ["user_id", "mentionable_type", "mentionable_id"], name: "index_mentions_on_user_and_target", unique: true
    t.index ["user_id"], name: "index_mentions_on_user_id"
  end

  create_table "moderation_logs", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "moderator_id", null: false
    t.string "reason"
    t.bigint "target_id", null: false
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_moderation_logs_on_created_at"
    t.index ["target_type", "target_id"], name: "index_moderation_logs_on_target_type_and_target_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id", null: false
    t.datetime "created_at", null: false
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.datetime "read_at"
    t.bigint "recipient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["recipient_id", "created_at"], name: "index_notifications_on_recipient_id_and_created_at"
    t.index ["recipient_id", "read_at"], name: "index_notifications_on_recipient_id_and_read_at"
  end

  create_table "replies", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "discussion_id", null: false
    t.boolean "is_accepted", default: false, null: false
    t.bigint "parent_reply_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "vote_score", default: 0, null: false
    t.index ["discussion_id", "created_at"], name: "index_replies_on_discussion_id_and_created_at"
    t.index ["discussion_id"], name: "index_replies_on_discussion_id"
    t.index ["is_accepted"], name: "index_replies_on_is_accepted"
    t.index ["parent_reply_id"], name: "index_replies_on_parent_reply_id"
    t.index ["status"], name: "index_replies_on_status"
    t.index ["user_id", "created_at"], name: "index_replies_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "reason", null: false
    t.bigint "reportable_id", null: false
    t.string "reportable_type", null: false
    t.bigint "reporter_id", null: false
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "discussion_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["discussion_id"], name: "index_subscriptions_on_discussion_id"
    t.index ["user_id", "discussion_id"], name: "index_subscriptions_on_user_id_and_discussion_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "discussions_count", default: 0, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "user_badges", force: :cascade do |t|
    t.datetime "awarded_at", null: false
    t.bigint "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id", "badge_id"], name: "index_user_badges_on_user_id_and_badge_id", unique: true
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.text "bio"
    t.datetime "created_at", null: false
    t.integer "discussions_count", default: 0, null: false
    t.string "display_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "location"
    t.datetime "remember_created_at"
    t.integer "replies_count", default: 0, null: false
    t.integer "reputation", default: 0, null: false
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "suspended_at"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "website"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reputation"], name: "index_users_on_reputation"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["suspended_at"], name: "index_users_on_suspended_at"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "value", null: false
    t.bigint "voteable_id", null: false
    t.string "voteable_type", null: false
    t.index ["user_id", "voteable_type", "voteable_id"], name: "index_votes_on_user_id_and_voteable_type_and_voteable_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
    t.index ["voteable_type", "voteable_id"], name: "index_votes_on_voteable_type_and_voteable_id"
  end

  add_foreign_key "bookmarks", "discussions", on_delete: :cascade
  add_foreign_key "bookmarks", "users"
  add_foreign_key "discussion_tags", "discussions", on_delete: :cascade
  add_foreign_key "discussion_tags", "tags", on_delete: :cascade
  add_foreign_key "discussions", "categories"
  add_foreign_key "discussions", "replies", column: "accepted_reply_id", on_delete: :nullify
  add_foreign_key "discussions", "users"
  add_foreign_key "mentions", "users", on_delete: :cascade
  add_foreign_key "moderation_logs", "users", column: "moderator_id", on_delete: :cascade
  add_foreign_key "notifications", "users", column: "actor_id", on_delete: :cascade
  add_foreign_key "notifications", "users", column: "recipient_id", on_delete: :cascade
  add_foreign_key "replies", "discussions", on_delete: :cascade
  add_foreign_key "replies", "replies", column: "parent_reply_id", on_delete: :nullify
  add_foreign_key "replies", "users"
  add_foreign_key "reports", "users", column: "reporter_id", on_delete: :cascade
  add_foreign_key "reports", "users", column: "reviewed_by_id", on_delete: :nullify
  add_foreign_key "subscriptions", "discussions", on_delete: :cascade
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_badges", "badges", on_delete: :cascade
  add_foreign_key "user_badges", "users", on_delete: :cascade
  add_foreign_key "votes", "users"
end
