class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable


  before_create :set_token

  private

  def set_token
    self.auth_token = Devise.friendly_token
  end

end
