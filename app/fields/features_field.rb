# app/fields/features_field.rb
require "administrate/field/base"

class FeaturesField < Administrate::Field::Base
  def to_s
    data
  end

  def features_hash
    data.present? ? data : {}
  end

  def feature_keys
    User.features
  end

  def feature_enabled?(feature)
    features_hash[feature] == true
  end
end
