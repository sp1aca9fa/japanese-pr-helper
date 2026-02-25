class ChatsController < ApplicationController
  before_action :set_user_application, only: %i[show create destroy]
  def show
    @chats = @user_application.chats.order(done: :asc, created_at: :desc)
    @chat = @user_application.chats.find_by(id: params[:id])

    return redirect_to_latest_open_chat_or_fallback unless @chat.present?

    @newchat = Chat.new
  end

  def create
    @newchat = Chat.new(chat_params)
    @newchat.user_application = @user_application
    if @newchat.save
      redirect_to user_application_chat_path(@user_application, @newchat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    chat = Chat.find(params[:id])
    chat.destroy
    redirect_to_latest_open_chat_or_fallback
  end

  def update
    @chat = Chat.find(params[:id])
    return unless @chat.update(done_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:title)
  end

  def done_params
    params.require(:chat).permit(:done)
  end

  def set_user_application
    @user_application = UserApplication.find(params[:user_application_id])
  end

  def redirect_to_latest_open_chat_or_fallback
    target_chat = @user_application.chats.where(done: false).order(id: :desc).first
    target_chat ||= @user_application.chats.order(id: :desc).first
    return redirect_to user_application_chat_path(@user_application, target_chat) if target_chat.present?

    redirect_to new_user_application_path
  end
end
