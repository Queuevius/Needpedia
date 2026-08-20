require "administrate/base_dashboard"

class ChatThreadDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    last_message: Field::Text,
    user: Field::BelongsTo,
    guest: Field::BelongsTo,
    chat_messages: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    title
    user
    guest
    last_message
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    title
    last_message
    user
    guest
    chat_messages
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    title
    last_message
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(thread)
    thread.title.presence || thread.thread_id
  end
end
