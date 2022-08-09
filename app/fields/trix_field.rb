require "administrate/field/base"

class TrixField < Administrate::Field::Base
  def to_s
    data
  end
end
