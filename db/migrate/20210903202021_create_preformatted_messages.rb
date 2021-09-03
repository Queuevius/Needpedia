class CreatePreformattedMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :preformatted_messages do |t|
      t.text :body
      t.string :for_post_type

      t.timestamps
    end
  end
end
