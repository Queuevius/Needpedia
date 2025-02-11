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

ActiveRecord::Schema.define(version: 2025_01_29_062311) do


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
    t.string "ip"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "admin_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action"
    t.string "target_type"
    t.bigint "target_id"
    t.text "message"
    t.string "ip_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_admin_histories_on_user_id"
  end

  create_table "admin_notices", force: :cascade do |t|
    t.string "key"
    t.text "content"
    t.string "color"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "admin_notifications", force: :cascade do |t|
    t.string "audience"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ai_tokens", force: :cascade do |t|
    t.integer "tokens_count", default: 0
    t.bigint "user_id"
    t.bigint "guest_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["guest_id"], name: "index_ai_tokens_on_guest_id"
    t.index ["user_id"], name: "index_ai_tokens_on_user_id"
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

  create_table "banned_terms", force: :cascade do |t|
    t.string "term"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "blocked_ips", force: :cascade do |t|
    t.string "ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "blocked_users", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "block_user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_blocked_users_on_user_id"
  end

  create_table "button_images", force: :cascade do |t|
    t.string "name"
    t.string "page_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "chat_threads", force: :cascade do |t|
    t.string "title"
    t.string "last_message"
    t.string "thread_id"
    t.bigint "user_id"
    t.bigint "guest_id"
    t.index ["guest_id"], name: "index_chat_threads_on_guest_id"
    t.index ["user_id"], name: "index_chat_threads_on_user_id"
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
    t.integer "group_id"
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

  create_table "deletion_requests", force: :cascade do |t|
    t.bigint "post_version_id", null: false
    t.bigint "user_id", null: false
    t.string "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_version_id"], name: "index_deletion_requests_on_post_version_id"
    t.index ["user_id"], name: "index_deletion_requests_on_user_id"
  end

  create_table "deletions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "deletable_id"
    t.string "deletable_type"
    t.string "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_deletions_on_user_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "registration_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "subject"
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

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "group_id"
    t.string "group_type"
    t.index ["user_id"], name: "index_groups_on_user_id"
  end

  create_table "guests", force: :cascade do |t|
    t.string "ip"
    t.string "uuid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "fingerprint"
    t.string "last_ip"
    t.string "user_agent"
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

  create_table "impacts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "description"
    t.string "badge"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_impacts_on_user_id"
  end

  create_table "interested_users", force: :cascade do |t|
    t.string "content"
    t.integer "parent_id"
    t.bigint "post_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_interested_users_on_post_id"
    t.index ["user_id"], name: "index_interested_users_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "group_id"
    t.integer "status", default: 0
    t.index ["group_id"], name: "index_invitations_on_group_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "likeable_id"
    t.string "likeable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "login_attempts", force: :cascade do |t|
    t.string "ip_address"
    t.datetime "attempted_at"
    t.boolean "success"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ip_address", "attempted_at"], name: "index_login_attempts_on_ip_address_and_attempted_at"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.string "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
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

  create_table "objectives", force: :cascade do |t|
    t.bigint "post_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "parent_id"
    t.string "body"
    t.index ["post_id"], name: "index_objectives_on_post_id"
    t.index ["user_id"], name: "index_objectives_on_user_id"
  end

  create_table "post_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id"
    t.string "content"
    t.string "post_token_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "group_id"
    t.integer "topic_id"
    t.index ["post_id"], name: "index_post_tokens_on_post_id"
    t.index ["user_id"], name: "index_post_tokens_on_user_id"
  end

  create_table "post_versions", force: :cascade do |t|
    t.bigint "post_id"
    t.text "content"
    t.datetime "modification_date"
    t.bigint "user_id"
    t.bigint "restored_by_id"
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_post_versions_on_post_id"
    t.index ["restored_by_id"], name: "index_post_versions_on_restored_by_id"
    t.index ["user_id"], name: "index_post_versions_on_user_id"
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
    t.datetime "deleted_at"
    t.datetime "restore_at"
    t.integer "group_id"
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

  create_table "related_contents", force: :cascade do |t|
    t.bigint "post_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "parent_id"
    t.string "body"
    t.index ["post_id"], name: "index_related_contents_on_post_id"
    t.index ["user_id"], name: "index_related_contents_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "group_id"
    t.integer "status", default: 0
    t.index ["group_id"], name: "index_requests_on_group_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
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

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "group_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "skills", default: [], array: true
    t.string "city"
    t.string "status", default: "Casual", null: false
    t.decimal "hours", precision: 5, scale: 2, default: "1.0", null: false
    t.index ["group_id"], name: "index_tasks_on_group_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
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

  create_table "topics", force: :cascade do |t|
    t.bigint "group_id"
    t.integer "parent_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_topics_on_group_id"
    t.index ["user_id"], name: "index_topics_on_user_id"
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

  create_table "tutorials", force: :cascade do |t|
    t.string "link"
    t.text "content"
    t.boolean "show"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_assistant_documents", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "change_log"
    t.integer "user_id"
    t.string "file_type"
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

  create_table "user_tutorials", force: :cascade do |t|
    t.string "link"
    t.text "content"
    t.boolean "viewed", default: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_tutorials_on_user_id"
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
    t.string "message_notifications", default: "non"
    t.string "track_notifications", default: "non"
    t.boolean "daily_notifications", default: false
    t.datetime "daily_notification_time"
    t.boolean "all_notifications", default: false
    t.datetime "daily_report_sent_at"
    t.boolean "master_admin", default: false
    t.boolean "approved", default: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.text "tokens"
    t.string "comment"
    t.integer "default_group_id"
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.jsonb "features", default: {}, null: false
    t.integer "failed_attempts"
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "otp_backup_codes", array: true
    t.integer "reset_password_attempts"
    t.datetime "last_reset_attempt_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_histories", "users"
  add_foreign_key "ai_tokens", "guests"
  add_foreign_key "ai_tokens", "users"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "chat_threads", "guests"
  add_foreign_key "chat_threads", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "deletion_requests", "post_versions"
  add_foreign_key "deletion_requests", "users"
  add_foreign_key "deletions", "users"
  add_foreign_key "devices", "users"
  add_foreign_key "feedback_question_options", "feedback_questions"
  add_foreign_key "flags", "users"
  add_foreign_key "gigs", "users"
  add_foreign_key "groups", "users"
  add_foreign_key "impacts", "users"
  add_foreign_key "interested_users", "users"
  add_foreign_key "invitations", "groups"
  add_foreign_key "invitations", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "objectives", "users"
  add_foreign_key "post_tokens", "posts", on_delete: :cascade
  add_foreign_key "post_tokens", "users"
  add_foreign_key "post_versions", "posts"
  add_foreign_key "post_versions", "users"
  add_foreign_key "post_versions", "users", column: "restored_by_id"
  add_foreign_key "posts", "users"
  add_foreign_key "questions", "questionnaires"
  add_foreign_key "ratings", "users"
  add_foreign_key "related_contents", "users"
  add_foreign_key "requests", "groups"
  add_foreign_key "requests", "users"
  add_foreign_key "services", "users"
  add_foreign_key "shares", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tasks", "users"
  add_foreign_key "token_ans_debates", "post_tokens"
  add_foreign_key "token_ans_debates", "posts"
  add_foreign_key "token_ans_debates", "users"
  add_foreign_key "topics", "groups"
  add_foreign_key "topics", "users"
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
  add_foreign_key "user_tutorials", "users"
end
