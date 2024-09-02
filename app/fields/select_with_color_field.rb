# app/fields/select_with_color_field.rb
require "administrate/field/base"

class SelectWithColorField < Administrate::Field::Base
  def to_s
    data
  end

  def collection
    options.fetch(:collection, [])
  end
end
