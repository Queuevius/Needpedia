class UserSearchService
  def initialize(params)
    @ransack_fields = params[:q]
  end

  attr_accessor :ransack_fields

  def filter
    query = ransack_fields[:title_cont].present? ? { first_name_or_last_name_or_full_name_cont: ransack_fields[:title_cont] } : ransack_fields
    User.ransack(query).result(distinct: true)
  end
end
