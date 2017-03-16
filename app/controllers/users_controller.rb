class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(auth_token: Devise.friendly_token)
    render :edit
  end
end
