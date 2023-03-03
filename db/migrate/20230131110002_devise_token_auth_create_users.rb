class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :provider, :null => false, :default => "email"
      t.string :uid, :null => false, :default => ""
      t.text :tokens
    end
  end
end
