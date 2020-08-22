require "administrate/base_dashboard"

class GigDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    body: Field::RichText,
    user: Field::BelongsTo,
    user_gigs: Field::HasMany,
    users: Field::HasMany,
    id: Field::Number,
    title: Field::String,
    area_tag: Field::String,
    body: Field::String,
    amount: Field::Number.with_options(decimals: 2),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status: Field::String,
    disabled: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  user
  title
  area_tag
  disabled
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  body
  user
  user_gigs
  users
  id
  title
  area_tag
  body
  amount
  created_at
  updated_at
  status
  disabled
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  body
  user
  user_gigs
  users
  title
  area_tag
  body
  amount
  status
  disabled
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how gigs are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(gig)
    gig.title
  end
end
