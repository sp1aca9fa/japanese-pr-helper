class UserApplicationsController < ApplicationController
  def index
    @user_applications = current_user.user_applications
  end

  def new
    @user_application = UserApplication.new
  end

  def create
    @user_application = UserApplication.new(user_application_params)
    @user_application.user = current_user
    if @user_application.save
      redirect_to new_user_application_chat_path(@user_application)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_application_params
    params.require(:user_application).permit(:application_journey_id, :title)
  end
end
