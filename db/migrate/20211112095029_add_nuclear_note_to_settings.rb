class AddNuclearNoteToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :active_nuclear_note, :boolean, default: false
    add_column :settings, :nuclear_note, :text
  end
end
