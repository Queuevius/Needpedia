class ChangeAreaToSubject < ActiveRecord::Migration[6.0]
  def self.up
   rename_column :posts, :area_id, :subject_id
 end

 def self.down
   rename_column :posts, :subject_id, :area_id
 end
end
