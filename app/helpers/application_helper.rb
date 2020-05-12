module ApplicationHelper
  def bootstrap_class_for(flash_type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def post_type_color(type)
    {
      idea: "text-success",
      problem: "text-danger",
      area: "text-primary",
      proposal: "text-purple"
    }.stringify_keys[type.to_s] || type.to_s
  end
end
