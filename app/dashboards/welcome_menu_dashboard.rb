require "administrate/base_dashboard"

class WelcomeMenuDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    content: SummernoteField,
    bg_image: Field::ActiveStorage,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    content
    updated_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    content
    bg_image
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    content
    bg_image
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
