class Event < ActiveRecord::Base

  belongs_to :keyword
  belongs_to :test_case
  has_attached_file :avatar

  validate :mandatory_arguments
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  private

  def mandatory_arguments
    args = keyword.mandatory_arguments
    # args.each do |arg|
    #   errors.add(arg.to_sym: 'asdf') if self.send(arg.to_sym).blank?
    # end
  end

end
