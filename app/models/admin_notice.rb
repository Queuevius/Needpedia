class AdminNotice < ApplicationRecord
  BOOTSTRAP_ALERT_CLASSES = {
      'None' => 'none',
      'Primary' => 'primary',
      'Secondary' => 'secondary',
      'Success' => 'success',
      'Danger' => 'danger',
      'Warning' => 'warning',
      'Info' => 'info',
      'Dark' => 'dark'
  }.freeze

  validates :color, inclusion: { in: BOOTSTRAP_ALERT_CLASSES.values }
end
