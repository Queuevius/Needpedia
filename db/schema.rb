# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_08_09_110741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "admin_notifications", force: :cascade do |t|
    t.string "audience"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "announcements", force: :cascade do |t|
    t.datetime "published_at"
    t.string "announcement_type"
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "answers", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id"
    t.bigint "question_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "blocked_users", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "block_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_blocked_users_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.string "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "parent_id"
    t.integer "status", default: 0
    t.boolean "inappropriate", default: false
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "connection_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.string "message"
    t.string "status", default: "pending"
    t.uuid "to"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.index ["user_id"], name: "index_connection_requests_on_user_id"
  end

  create_table "connections", force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "friend_id"], name: "index_connections_on_user_id_and_friend_id", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "faqs", force: :cascade do |t|
    t.text "question"
    t.text "answer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "feedback_question_options", force: :cascade do |t|
    t.text "body"
    t.bigint "feedback_question_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feedback_question_id"], name: "index_feedback_question_options_on_feedback_question_id"
  end

  create_table "feedback_questions", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "feedback_responses", force: :cascade do |t|
    t.bigint "feedback_id"
    t.bigint "feedback_question_id"
    t.bigint "feedback_question_option_id"
    t.text "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feedback_id"], name: "index_feedback_responses_on_feedback_id"
    t.index ["feedback_question_id"], name: "index_feedback_responses_on_feedback_question_id"
    t.index ["feedback_question_option_id"], name: "index_feedback_responses_on_feedback_question_option_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "flags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "flagable_id"
    t.string "flagable_type"
    t.string "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_flags_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "gigs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "area_tag"
    t.string "body"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "pending"
    t.boolean "disabled", default: false
    t.index ["user_id"], name: "index_gigs_on_user_id"
  end

  create_table "home_videos", force: :cascade do |t|
    t.string "link"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "how_tos", force: :cascade do |t|
    t.text "question"
    t.text "answer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "likeable_id"
    t.string "likeable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "conversation_id", null: false
    t.datetime "read_at"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "receiver_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "post_id"
    t.boolean "edit_post"
    t.boolean "expert_layer"
    t.boolean "related_wiki_post"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "recipient_id"
    t.bigint "actor_id"
    t.datetime "read_at"
    t.string "action"
    t.bigint "notifiable_id"
    t.string "notifiable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "post_id"
    t.integer "admin_notification_id"
  end

  create_table "post_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.string "content"
    t.string "post_token_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_post_tokens_on_post_id"
    t.index ["user_id"], name: "index_post_tokens_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "post_type"
    t.bigint "user_id", null: false
    t.string "title"
    t.integer "subject_id"
    t.integer "problem_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "post_id"
    t.boolean "disabled", default: false
    t.boolean "private", default: false
    t.boolean "editing_disabled", default: false
    t.boolean "layering_disabled", default: false
    t.boolean "curated", default: false
    t.integer "posted_to_id"
    t.decimal "lat"
    t.decimal "long"
    t.boolean "geo_maxing", default: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "preformatted_messages", force: :cascade do |t|
    t.text "body"
    t.string "for_post_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "questionnaires", force: :cascade do |t|
    t.text "title"
    t.boolean "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "questionnaire_id", null: false
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["questionnaire_id"], name: "index_questions_on_questionnaire_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "rating"
    t.bigint "rateable_id"
    t.string "rateable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "access_token_secret"
    t.string "refresh_token"
    t.datetime "expires_at"
    t.text "auth"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_services_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "freeze_accounts_activity", default: false
    t.boolean "freeze_posts_activity", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active_nuclear_note", default: false
    t.text "nuclear_note"
  end

  create_table "shares", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "shareable_id"
    t.string "shareable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_shares_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tests", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "token_ans_debates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.bigint "post_token_id", null: false
    t.string "content"
    t.string "debate_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_token_ans_debates_on_post_id"
    t.index ["post_token_id"], name: "index_token_ans_debates_on_post_token_id"
    t.index ["user_id"], name: "index_token_ans_debates_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "recipient_id"
    t.bigint "actor_id"
    t.string "transaction_type"
    t.float "amount"
    t.bigint "gig_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_conversations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conversation_id"], name: "index_user_conversations_on_conversation_id"
    t.index ["user_id"], name: "index_user_conversations_on_user_id"
  end

  create_table "user_curated_posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_user_curated_posts_on_post_id"
    t.index ["user_id"], name: "index_user_curated_posts_on_user_id"
  end

  create_table "user_gigs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "gig_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gig_id"], name: "index_user_gigs_on_gig_id"
    t.index ["user_id"], name: "index_user_gigs_on_user_id"
  end

  create_table "user_posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.string "post_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_user_posts_on_post_id"
    t.index ["user_id"], name: "index_user_posts_on_user_id"
  end

  create_table "user_private_posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_user_private_posts_on_post_id"
    t.index ["user_id"], name: "index_user_private_posts_on_user_id"
  end

  create_table "user_questionnaires", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "questionnaire_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["questionnaire_id"], name: "index_user_questionnaires_on_questionnaire_id"
    t.index ["user_id"], name: "index_user_questionnaires_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.datetime "announcements_last_read_at"
    t.boolean "admin", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.string "location"
    t.text "about"
    t.boolean "disabled", default: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "last_login_at"
    t.boolean "message_notifications", default: false
    t.boolean "track_notifications", default: false
    t.boolean "daily_notifications", default: false
    t.datetime "daily_notification_time"
    t.boolean "all_notifications", default: false
    t.datetime "daily_report_sent_at"
    t.boolean "master_admin", default: false
    t.boolean "approved", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "feedback_question_options", "feedback_questions"
  add_foreign_key "flags", "users"
  add_foreign_key "gigs", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "post_tokens", "posts"
  add_foreign_key "post_tokens", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "questions", "questionnaires"
  add_foreign_key "ratings", "users"
  add_foreign_key "services", "users"
  add_foreign_key "shares", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "token_ans_debates", "post_tokens"
  add_foreign_key "token_ans_debates", "posts"
  add_foreign_key "token_ans_debates", "users"
  add_foreign_key "user_conversations", "conversations"
  add_foreign_key "user_conversations", "users"
  add_foreign_key "user_curated_posts", "posts"
  add_foreign_key "user_curated_posts", "users"
  add_foreign_key "user_gigs", "gigs"
  add_foreign_key "user_gigs", "users"
  add_foreign_key "user_posts", "posts"
  add_foreign_key "user_posts", "users"
  add_foreign_key "user_private_posts", "posts"
  add_foreign_key "user_private_posts", "users"
  add_foreign_key "user_questionnaires", "questionnaires"
  add_foreign_key "user_questionnaires", "users"
end
