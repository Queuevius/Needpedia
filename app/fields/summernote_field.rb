require "administrate/field/base"

class SummernoteField < Administrate::Field::Base
  def to_s
    data
  end
end
