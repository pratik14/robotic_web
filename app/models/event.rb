class Event < ActiveRecord::Base

  attr_accessor :width, :height

  belongs_to :keyword
  belongs_to :test_case
  has_attached_file :avatar

  validate :mandatory_arguments, unless: Proc.new {|e| e.new_record? }
  validates :order_number, :uniqueness => {:scope => :test_case_id}, numericality: true
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  default_scope { order(order_number: :asc) }


  def width
    '1200'
  end

  def height
    '1200'
  end

  private

  def mandatory_arguments
    keyword.required_args.each do |arg|
      errors.add("arg.to_sym" => 'should not be blank') if self.send(arg.to_sym).blank?
    end
  end
end
