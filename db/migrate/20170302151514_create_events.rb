class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :test_case, index: true
      t.belongs_to :keyword, index: true
      t.string  :url
      t.string  :locator
      t.string  :text
      t.string  :expected
      t.string  :value
      t.string  :message
      t.string  :status
      t.timestamps
    end
  end
end
