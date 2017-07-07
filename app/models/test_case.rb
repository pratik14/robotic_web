class TestCase < ActiveRecord::Base
  include TestCases::RobotFile

  belongs_to :user
  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :events, reject_if: :all_blank, allow_destroy: true

  has_attached_file :source_file
  validates_attachment_content_type :source_file, content_type: ["text/plain", "text/x-r", "text/x-patch", "text/x-diff"]

  validates_associated :events

  #before_save :attach_file

  def screenshot
    begin
      failed_event.avatar.url
    rescue 
      return '--'
    end
  end

  def failed_event
    events.where(status: 'FAIL').first
  end

  def passed?
    status == 'PASS'
  end

  def failed?
    status == 'FAIL'
  end

  def verify
    restore_test_db
    generate
    ExecuteTestCaseWorker.perform_async(id)
  end

  def restore_test_db
    uri = URI(user.setup_url)
    Net::HTTP.get(uri)
  end

  def attach_file
    generate
    self.source_file =  File.open(file_path)
  end

  def file_path
    dir_path = "#{Rails.root}/tmp/robot_file/#{id}/"
    Dir.mkdir(dir_path) unless File.exists?(dir_path)
    dir_path + file_name
  end

  def file_name
    "#{self.name.parameterize.underscore}.txt"
  end
end
