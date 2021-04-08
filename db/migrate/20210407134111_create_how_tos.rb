class CreateHowTos < ActiveRecord::Migration[6.0]
  def change
    create_table :how_tos do |t|
      t.text :question
      t.text :answer

      t.timestamps
    end
  end
end
