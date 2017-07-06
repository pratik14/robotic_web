class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if params[:commit] == 'Generate New Token'
      @user.update_attributes(auth_token: Devise.friendly_token)
    else
      @user.update_attributes(update_params)
    end
    render :edit
  end

  private

  def update_params
    params.require(:user).permit(:email, :setup_url)
  end
end
