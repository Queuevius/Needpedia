require "administrate/base_dashboard"

class PostDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    content: Field::RichText,
    user: Field::BelongsTo,
    parent_subject: Field::BelongsTo.with_options(class_name: "Post", forign_key: 'subject_id'),
    child_posts: Field::HasMany.with_options(class_name: "Post", forign_key: 'subject_id'),
    problem: Field::BelongsTo.with_options(class_name: "Post", forign_key: 'subject_id'),
    ideas: Field::HasMany.with_options(class_name: "Post", forign_key: 'problem_id'),
    parent_post: Field::BelongsTo.with_options(class_name: "Post", forign_key: 'problem_id'),
    layers: Field::HasMany.with_options(class_name: "Post", forign_key: 'post_id'),
    comments: Field::HasMany,
    flags: Field::HasMany,
    id: Field::Number,
    post_type: Field::String,
    title: Field::String,
    subject_id: Field::Number,
    problem_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    post_id: Field::Number,
    disabled: Field::Boolean,
    editing_disabled: Field::Boolean,
    layering_disabled: Field::Boolean,
    private: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  post_type
  title
  private
  user
  disabled
  editing_disabled
  layering_disabled
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  content
  user
  parent_subject
  child_posts
  problem
  ideas
  parent_post
  layers
  comments
  disabled
  editing_disabled
  layering_disabled
  flags
  id
  post_type
  title
  subject_id
  problem_id
  created_at
  updated_at
  post_id
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  content
  user
  comments
  flags
  post_type
  disabled
  editing_disabled
  layering_disabled
  title
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
  COLLECTION_FILTERS = {
    private: ->(resources) { resources.where(private: true) },
    curated: ->(resources) { resources.where(curated: true) },
    public: ->(resources) { resources.where(private: false) },
    all: -> (resources) { resources }
  }.freeze

  # Overwrite this method to customize how posts are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(post)
    post.title
  end
end
