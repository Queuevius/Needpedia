class UserSearchService
  def initialize(params)
    @ransack_fields = params[:q]
  end

  attr_accessor :ransack_fields

  def filter
    q = User.ransack(ransack_fields)
    q.result(distinct: true)
  end
end