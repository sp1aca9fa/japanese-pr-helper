class UserApplicationsController < ApplicationController
  def new
    @user_application = UserApplication.new
  end
end
