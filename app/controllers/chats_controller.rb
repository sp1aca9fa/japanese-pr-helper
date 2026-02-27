class ChatsController < ApplicationController
  before_action :set_user_application, only: %i[show create destroy]
  def show
    @chats = @user_application.chats.order(pin: :desc, done: :asc, created_at: :desc)
    @chat = @user_application.chats.find_by(id: params[:id])
    @messages_with_files = @chat.messages
                                .joins(:file_attachment)
                                .with_attached_file
    initial_message if @chat.messages.empty? && !@chat.system_prompt.nil?
    @message = Message.new
    return redirect_to_latest_open_chat_or_fallback unless @chat.present?

    @newchat = Chat.new
  end

  def create
    @newchat = Chat.new(chat_params)
    @newchat.user_application = @user_application
    if @newchat.save
      redirect_to user_application_chat_path(@user_application, @newchat)
    else
      target_chat = target_chat(@user_application)
      redirect_to user_application_chat_path(@user_application, target_chat), alert: 'Title Existed!'
    end
  end

  def destroy
    chat = Chat.find(params[:id])
    chat.destroy
    redirect_to_latest_open_chat_or_fallback
  end

  def update
    @chat = Chat.find(params[:id])
    @user_application = @chat.user_application
    return unless @chat.update(done_params)

    @chats = @user_application.chats.order(pin: :desc, done: :asc, created_at: :desc)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def toggle_pin
    @user_application = UserApplication.find(params[:user_application_id])
    @chat = @user_application.chats.find_by(id: params[:id])
    @chat.update(pin: !@chat.pin)
    @chats = @user_application.chats.order(pin: :desc, done: :asc, created_at: :desc)
    respond_to do |format|
      format.html { redirect_back fallback_location: user_application_chat_path(@user_application, @chat) }
      format.turbo_stream
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
    target_chat = target_chat(@user_application)
    if target_chat.present?
      redirect_to user_application_chat_path(@user_application, target_chat), status: :see_other
    else
      @user_application.destroy
      redirect_to user_applications_path(user_id: current_user.id), status: :see_other
    end
  end

  def target_chat(user_application)
    chat = user_application.chats.where(pin: true, done: false).order(id: :desc).first
    chat ||= user_application.chats.where(pin: true).order(id: :desc).first
    chat ||= user_application.chats.where(done: false).order(id: :desc).first
    chat ||= user_application.chats.order(id: :desc).first
    chat
  end

  def initial_context
    <<~PROMPT
      You are an assistant helping users prepare a Japanese Permanent Residency (PR) application.
      A new application has just been created. A dedicated chat exists for each required document.
      Your task is to generate the FIRST message of the chat.
      Using the application details provided as context, explain:
      1. What this document is.
      2. Why it is required for the PR application.
      3. The main steps required to obtain it.
      4. Important cautions or common difficulties if relevant.
      Guidelines:
      - Be concise and practical.
      - Prioritize actionable information.
      - Avoid greetings, emojis, or conversational filler.
      - Do not use decorative language.
      - Use plain text formatting, except for:
        - A clear title
        - Short subtitles when helpful
        - Bullet point lists.
      The response should feel like a professional instruction guide.
      ASIDES FROM DOCUMENT NAMES, MAKE SURE THE LANGUAGE USED IS ENGLISH.
      Additional context about the application:
      #{@chat.system_prompt}
      #{@user_application.application_journey.system_prompt}
      #{@user_application.application_journey.description}
    PROMPT
  end

  def initial_message
    @ruby_llm_chat = RubyLLM.chat(model: 'gpt-5-mini')
    response = @ruby_llm_chat.ask(initial_context)
    Message.create(role: "assistant", content: response.content, chat: @chat)
  end
end
