class CreateHomeVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :home_videos do |t|
      t.string :link

      t.timestamps
    end
  end
end
