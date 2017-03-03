class AddAttachmentSourceFileToTestCases < ActiveRecord::Migration
  def self.up
    change_table :test_cases do |t|
      t.attachment :source_file
    end
  end

  def self.down
    remove_attachment :test_cases, :source_file
  end
end
