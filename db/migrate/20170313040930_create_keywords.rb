class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :name
      t.text   :documentation
      t.text   :arguments, array: true, default: []
      t.text   :mandatory_arguments, array: true, default: []

      t.timestamps
    end
  end
end
