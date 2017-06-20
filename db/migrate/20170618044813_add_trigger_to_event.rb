class AddTriggerToEvent < ActiveRecord::Migration
  def change
    add_column :events, :trigger, :string
  end
end
