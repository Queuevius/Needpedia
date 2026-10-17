require "administrate/base_dashboard"

class WelcomeMenuDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    content: SummernoteField,
    onboarding_text: SummernoteField,
    button_no_ai_label: Field::String,
    button_ai_label: Field::String,
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
    onboarding_text
    button_no_ai_label
    button_ai_label
    bg_image
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    content
    onboarding_text
    button_no_ai_label
    button_ai_label
    bg_image
  ].freeze

  COLLECTION_FILTERS = {}.freeze
end
