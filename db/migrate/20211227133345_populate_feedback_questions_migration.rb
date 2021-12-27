class PopulateFeedbackQuestionsMigration < ActiveRecord::Migration[6.0]
  def change
    Rake::Task['populate_feeback_data:process'].invoke
  end
end
