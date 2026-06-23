class AiPrompt < ApplicationRecord
  TYPES = %w[Lotte Florence Adele].freeze

  validates :ai_type, presence: true, inclusion: { in: TYPES }
  validates :description, presence: true
  validates :version, presence: true,
                      numericality: { only_integer: true, greater_than: 0 }

  scope :by_type, -> (type) { where(ai_type: type).order(version: :desc) }
  scope :active_for_type, -> (type) { where(ai_type: type, active: true) }

  before_validation :assign_version, on: :create
  before_create :deactivate_previous_versions
  before_destroy :activate_previous_version, if: :active?

  def activate
    AiPromptActivator.call(self)
  end

  private

  def assign_version
    max_version = AiPrompt.where(ai_type: ai_type)
                          .maximum(:version) || 0
    self.version = max_version + 1
    self.active = true
  end

  def deactivate_previous_versions
    AiPrompt.where(ai_type: ai_type, active: true)
            .where.not(id: id)
            .update_all(active: false)
  end

  def activate_previous_version
    previous = AiPrompt.where(ai_type: ai_type)
                       .where("version < ?", version)
                       .order(version: :desc)
                       .first
    previous&.activate
  end
end
