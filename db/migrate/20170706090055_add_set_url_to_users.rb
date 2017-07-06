class AddSetUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :setup_url, :string
  end
end
