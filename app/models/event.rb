class Event < ActiveRecord::Base

  belongs_to :test_case
  has_attached_file :avatar

  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

end
