class MessagesController < ApplicationController
  # setting max token sizes for context and safe_limit
  MAX_CONTEXT = 100_000
  RESERVED_RESPONSE = 2000
  RESERVED_NEW_MESSAGE = 2000

  SAFE_LIMIT = MAX_CONTEXT - RESERVED_RESPONSE - RESERVED_NEW_MESSAGE

  before_action :set_chat, only: [:create]
  before_action :build_llm, only: [:create]
  before_action :build_chat_history, only: [:create]
  before_action :set_context, only: [:create]

  def create
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      llm_response

      respond_to do |format|
        format.html { redirect_to chat_path(@chat) }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render "chats/show", status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("new_message", partial: "messages/form",
                                                                  locals: { chat: @chat, message: @message })
        end
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
    @ruby_llm_chat = RubyLLM.chat
  end

  # 3- intructions to summarize chat_history (used in the next method)
  def summarize_instructions
    <<~PROMPT
      Objective: prepare a summary of chat history.
      Details: the current chat history is about to be destroyed and replaced with the returned summary of this ask.
      Token capability is reaching limit and there is no option but to replace the chat history with a summary.
      Prepare a summary as detailed as possible and as long as possible, desired token usage is 30,000 tokens (no more, no less).
      Keep key information provided by the user as profile information to be displayed at the top of the summary.
      After profile info, 2nd priority is to keep user input as much as possible (unless not relevant to the context of Japanese PR visa application).
      Final priority is to keep relevant information as much as possible, both from AI assistant and user.
      The result is to be interpreted by AI and will not be displayed to humans, so please feel free to optimize for AI context.
    PROMPT
  end

  # 4- summarize chat to use when building the chat_history(step4) if needed
  # just to make sure the app wont unexpectedly fail, very simple implementation
  def summarize_chat
    recent_messages = @chat.messages.order(:created_at).last(20)
    summary = @ruby_llm_chat.with_instructions(summarize_instructions).ask(recent_messages)
    # I'm not sure if the line below would work, but Chappy says it should.
    @chat.messages.destroy(recent_messages)
    @ruby_llm_chat.add_message(summary)
  end

  # 5- building the chat history and using summarize_chat only if too many tokens already used
  def build_chat_history
    # counting all tokens (per ruby llm documentation)
    total_chat_tokens = @chat.messages.sum { |msg| msg.content.length / 4 }

    if total_chat_tokens >= SAFE_LIMIT * 0.9
      summarize_chat
    else
      @chat.messages.each do |message|
        @ruby_llm_chat.add_message(
          role: message.role,
          content: message.content
        )
      end
    end
  end

  # 6- Setting the llm chat context
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

  # 7- Sending question to and receiving answer from the llm
  def llm_response
    build_chat_history
    if @message.file.attached?
      response = @ruby_llm_chat.with_instructions(set_context).ask(@message.content, with: { pdf: @message.file })
    else
      response = @ruby_llm_chat.with_instructions(set_context).ask(@message.content)
    end
    Message.create(role: "assistant", content: response.content, chat: @chat)
  end

  # Unrelated to above / setting message_params to avoid unwanted columns
  def message_params
    params.require(:message).permit(:content, :file)
  end
end
