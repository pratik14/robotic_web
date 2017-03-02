class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :test_case, index: true
      t.string  :locator
      t.string  :keyword
      t.string  :value
      t.string  :element
      t.string  :message
      t.string  :status
      t.timestamps
    end
  end
end
