class UserApplicationsController < ApplicationController
  def new
    @user_application = UserApplication.new
  end

  def create
    @user_application = UserApplication.new(user_application_params)
  end

  private

  def user_application_params
    params.require(:user_application).permit(:title)
  end
end
