class UserAssistantDocument < ApplicationRecord
  has_one_attached :file
  validates :file, presence: true
  validate :file_format

  def file_url
    Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
    # this is for production #
    # Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false)
  end

  private

  def file_format
    if file.attached? && !file.content_type.in?(%w(application/pdf))
      errors.add(:file, 'must be a PDF')
    end
  end
end
