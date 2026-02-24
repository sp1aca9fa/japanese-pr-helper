class MessagesController < ApplicationController
  before_action :set_chat, only: [:create]
  # before_action :set_chat_history, only: [:create]
  before_action :set_history_and_context, only: [:create]
  def create
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      response = message_response
      Message.create(role: "assistant", content: response.content, chat: @chat)

      redirect_to chat_path(@chat)
    else
      render chat_path(@chat), status: :unprocessable_entity
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  # TODO: add previous messages if any for context
  # def set_chat_history
  # end

  def set_history_and_context
    @application_journey = @chat.user_application.application_journey
    prompt1 = "Here is the application description: #{@application_journey.description}."
    prompt2 = "Here are some additional instructions (if any): #{@application_journey.system_prompt}."
    return "#{prompt1}\n#{prompt2}"
    # TODO: include the line below once chat history is implemented
    # Finally, here is the chat history (if any): #{set_chat_history}.\n
  end

  def message_response
    ruby_llm_chat = RubyLLM.chat(model: 'gpt-4o')
    return ruby_llm_chat.with_instructions(set_history_and_context).ask(@message.content)
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
