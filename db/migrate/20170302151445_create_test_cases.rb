class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.string :status
      t.string :message

      t.timestamps
    end
  end
end
