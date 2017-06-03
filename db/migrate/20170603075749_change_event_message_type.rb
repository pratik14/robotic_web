class ChangeEventMessageType < ActiveRecord::Migration
  def change
    change_column :events, :message, :text
  end
end
