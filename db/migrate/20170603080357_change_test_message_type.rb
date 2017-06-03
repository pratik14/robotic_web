class ChangeTestMessageType < ActiveRecord::Migration
  def change
    change_column :test_cases, :message, :text
  end
end
