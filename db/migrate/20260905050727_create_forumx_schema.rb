class CreateForumxSchema < ActiveRecord::Migration[8.1]
  def change
    # 1. Users
    create_table :users do |t|
      ## Devise fields
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      ## Profile & community fields
      t.string :username, null: false
      t.string :display_name
      t.text :bio
      t.string :website
      t.string :location
      t.string :avatar_url
      t.integer :role, default: 0, null: false
      t.integer :reputation, default: 0, null: false
      t.datetime :suspended_at
      t.integer :discussions_count, default: 0, null: false
      t.integer :replies_count, default: 0, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :role
    add_index :users, :reputation
    add_index :users, :suspended_at

    # 2. Categories
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :icon, default: "folder", null: false
      t.string :color_accent, default: "#6366f1", null: false
      t.integer :discussions_count, default: 0, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :position

    # 3. Discussions
    create_table :discussions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body, null: false
      t.integer :status, default: 0, null: false
      t.boolean :pinned, default: false, null: false
      t.bigint :accepted_reply_id
      t.integer :view_count, default: 0, null: false
      t.integer :vote_score, default: 0, null: false
      t.integer :reply_count, default: 0, null: false

      t.timestamps
    end

    add_index :discussions, :slug, unique: true
    add_index :discussions, [:category_id, :created_at]
    add_index :discussions, [:user_id, :created_at]
    add_index :discussions, :status
    add_index :discussions, :pinned
    add_index :discussions, :vote_score
    add_index :discussions, :view_count
    add_index :discussions, :reply_count
    add_index :discussions, :created_at

    # 4. Replies
    create_table :replies do |t|
      t.references :discussion, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: true
      t.bigint :parent_reply_id
      t.text :body, null: false
      t.integer :vote_score, default: 0, null: false
      t.boolean :is_accepted, default: false, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :replies, [:discussion_id, :created_at]
    add_index :replies, [:user_id, :created_at]
    add_index :replies, :parent_reply_id
    add_index :replies, :is_accepted
    add_index :replies, :status
    add_foreign_key :replies, :replies, column: :parent_reply_id, on_delete: :nullify
    add_foreign_key :discussions, :replies, column: :accepted_reply_id, on_delete: :nullify

    # 5. Tags
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :discussions_count, default: 0, null: false

      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true

    # 6. Discussion Tags
    create_table :discussion_tags do |t|
      t.references :discussion, null: false, foreign_key: { on_delete: :cascade }
      t.references :tag, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :discussion_tags, [:discussion_id, :tag_id], unique: true
    add_index :discussion_tags, [:tag_id, :discussion_id]

    # 7. Votes (polymorphic)
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :voteable_type, null: false
      t.bigint :voteable_id, null: false
      t.integer :value, null: false # +1 or -1

      t.timestamps
    end

    add_index :votes, [:user_id, :voteable_type, :voteable_id], unique: true
    add_index :votes, [:voteable_type, :voteable_id]

    # 8. Bookmarks
    create_table :bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :discussion, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :bookmarks, [:user_id, :discussion_id], unique: true

    # 9. Subscriptions
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :discussion, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :subscriptions, [:user_id, :discussion_id], unique: true

    # 10. Notifications
    create_table :notifications do |t|
      t.bigint :recipient_id, null: false
      t.bigint :actor_id, null: false
      t.string :notifiable_type, null: false
      t.bigint :notifiable_id, null: false
      t.string :action, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, [:recipient_id, :read_at]
    add_index :notifications, [:recipient_id, :created_at]
    add_index :notifications, [:notifiable_type, :notifiable_id]
    add_foreign_key :notifications, :users, column: :recipient_id, on_delete: :cascade
    add_foreign_key :notifications, :users, column: :actor_id, on_delete: :cascade

    # 11. Mentions
    create_table :mentions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :mentionable_type, null: false
      t.bigint :mentionable_id, null: false

      t.timestamps
    end

    add_index :mentions, [:user_id, :mentionable_type, :mentionable_id], unique: true, name: "index_mentions_on_user_and_target"
    add_index :mentions, [:mentionable_type, :mentionable_id]

    # 12. Reports
    create_table :reports do |t|
      t.bigint :reporter_id, null: false
      t.string :reportable_type, null: false
      t.bigint :reportable_id, null: false
      t.string :reason, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.bigint :reviewed_by_id
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :reports, :status
    add_index :reports, [:reportable_type, :reportable_id]
    add_foreign_key :reports, :users, column: :reporter_id, on_delete: :cascade
    add_foreign_key :reports, :users, column: :reviewed_by_id, on_delete: :nullify

    # 13. Moderation Logs
    create_table :moderation_logs do |t|
      t.bigint :moderator_id, null: false
      t.string :target_type, null: false
      t.bigint :target_id, null: false
      t.string :action, null: false
      t.string :reason
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :moderation_logs, :created_at
    add_index :moderation_logs, [:target_type, :target_id]
    add_foreign_key :moderation_logs, :users, column: :moderator_id, on_delete: :cascade

    # 14. Badges & User Badges
    create_table :badges do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :icon, null: false
      t.string :badge_type, default: "bronze", null: false

      t.timestamps
    end

    add_index :badges, :slug, unique: true

    create_table :user_badges do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :badge, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :awarded_at, null: false

      t.timestamps
    end

    add_index :user_badges, [:user_id, :badge_id], unique: true

    # 15. PostgreSQL Full-Text Search GIN index on discussions
    execute <<-SQL
      CREATE INDEX index_discussions_on_fts ON discussions
      USING gin(to_tsvector('english', coalesce(title, '') || ' ' || coalesce(body, '')));
    SQL
  end
end
