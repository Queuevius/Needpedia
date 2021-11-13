class Setting < ApplicationRecord
  def self.accounts_freezed
    Setting.first&.freeze_accounts_activity
  end

  def self.posts_freezed
    Setting.first&.freeze_posts_activity
  end

  def self.nuclear_note_active?
    Setting.first&.active_nuclear_note && !Setting.first&.nuclear_note.blank?
  end
end
