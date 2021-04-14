class AddDailyReportSentAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :daily_report_sent_at, :datetime
  end
end
