class AddUuidToAllModels < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'uuid-ossp' # => http://theworkaround.com/2015/06/12/using-uuids-in-rails.html#postgresql
    add_column :users, :uuid, :uuid, default: "uuid_generate_v4()", null: false
    add_column :connection_requests, :uuid, :uuid, default: "uuid_generate_v4()", null: false
  end
end
