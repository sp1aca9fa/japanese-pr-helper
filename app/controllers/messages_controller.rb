class MessagesController < ApplicationController
  # setting max token sizes for context and safe_limit
  MAX_CONTEXT = 100_000
  RESERVED_RESPONSE = 2000
  RESERVED_NEW_MESSAGE = 2000

  SAFE_LIMIT = MAX_CONTEXT - RESERVED_RESPONSE - RESERVED_NEW_MESSAGE

  before_action :set_chat, only: [:create]
  before_action :summarize_chat, only: [:create]
  before_action :build_chat_history, only: [:create]
  before_action :set_context, only: [:create]

  def create
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      llm_response

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("new_message", partial: "messages/form", locals: { chat: @chat, message: @message }) }
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  # 1- set the chat
  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  # 2- start the chat with llm
  def build_llm
    @ruby_llm_chat = RubyLLM.chat(model: 'gpt-4o')
  end

  # 3- summarize chat to use when building the chat_history(step4) if needed
  def summarize_chat
    chat_length = @chat.messages.length
    # using min between chat_length and 20 instead of ternary per linter suggestion
    recent_messages = @chat.messages.last([chat_length, 20].min)
    summary = @chat.with_instructions(summarize_instructions).ask(recent_messages)
    # I'm not sure if the line below would work, but Chappy says it should.
    @chat.messages.destroy(recent_messages)
    @ruby_llm_chat.add_message(summary)
  end

  # 4- building the chat history and using summarize_chat only if too many tokens already used
  # summarize_chat just to make sure the app wont unexpectedly fail, very simple implementation
  def build_chat_history
    # counting all tokens (per ruby llm documentation)
    total_chat_tokens = @chat.messages.sum { |msg| (msg.input_tokens || 0) + (msg.output_tokens || 0) }

    if total_chat_tokens >= SAFE_LIMIT * 0.9
      summarize_chat
    else
      @chat.messages.each do |message|
        @ruby_llm_chat.add_message(message)
      end
    end
  end

  # 5- Setting the llm chat context
  def set_context
    @application_journey = @chat.user_application.application_journey
    <<~PROMPT
      Japanese permanent visa application, type/category: #{@application_journey.description}.
      The type of permanent visa application is: #{@application_journey.system_prompt}.
      Need help acquiring #{@chat.system_prompt} related documents for the application.
      Keep objective to application. Minimize unnecessary interactions. Keep text formation minimalistic.
      Start the answer with an ordered TO DO list if applicable.
      If the asked information is not related to Japanese permanent visa application and its relevant documents,
      please simply reply with "Please refrain from making unrelated questions/requests"
    PROMPT
  end

  # 6- Sending question to and receiving answer from the llm
  def llm_response
    build_chat_history
    response = @ruby_llm_chat.with_instructions(set_context).ask(@message.content)
    Message.create(role: "assistant", content: response.content, chat: @chat)
  end

  # Unrelated to above / setting message_params to avoid unwanted columns
  def message_params
    params.require(:message).permit(:content)
  end
end
