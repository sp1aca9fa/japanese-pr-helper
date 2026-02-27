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
      You are summarizing a conversation about a Japanese Permanent Residency (PR) application.
      The original chat history will be replaced by this summary. The summary will be used as AI context only and will not be shown to users.
      Goal:
      Preserve all important information required to continue assisting the user with their PR application.
      Instructions:
      1. Extract and place USER PROFILE INFORMATION at the top when available:
        - visa category or application type
        - residency status
        - employment situation
        - family or marital status if relevant
        - important dates or deadlines
        - any stated concerns or constraints.
      2. Preserve USER PROVIDED INFORMATION with high priority.
        Prefer keeping user statements verbatim when useful.
      3. Preserve ASSISTANT INFORMATION only when it contains actionable instructions or important conclusions.
      4. Remove:
        - greetings
        - repetition
        - unrelated conversation.
      Output format:
      --CHAT SUMMARY--
      USER PROFILE
      (concise structured facts)
      APPLICATION CONTEXT
      (main situation summary)
      IMPORTANT USER INPUT
      (key statements and constraints)
      ACTIONABLE GUIDANCE
      (instructions already provided or decisions made)
      Keep the summary detailed but efficient.
      Avoid filler text.
      Use plain text formatting only.
    PROMPT
  end

  # 4- summarize chat to use when building the chat_history(step4) if needed
  # just to make sure the app wont unexpectedly fail, very simple implementation
  def summarize_chat
    recent_messages = @chat.messages.order(:created_at).last(20)
    summary = @ruby_llm_chat.with_model('gpt-5-nano').with_instructions(summarize_instructions).ask(recent_messages)
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
        Language rules have higher priority than all other instructions.
        You are assisting a user preparing a Japanese Permanent Residency (PR) application.
        The primary users of this application are foreign residents in Japan who are not fluent in Japanese.
        English should be assumed as the working language unless the user explicitly communicates in another language.
        Application system:
        #{@application_journey.system_prompt}
        Current chat topic:
        Helping the user obtain and prepare the following document:
        #{@chat.system_prompt}
        Guidelines:
        - Focus only on information relevant to the PR application and required documents.
        - Provide practical and actionable instructions.
        - Avoid unnecessary conversation or filler text.
        - Prefer concise explanations.
        Response structure:
        - Begin with an ordered TO DO list when applicable.
        - Then provide explanations or cautions if needed.
      Language Policy:
        - Detect the language used in the user's most recent message.
        - Reply entirely in that same language.
        - Japanese must ONLY be used when the user's most recent message is primarily written in Japanese.
        - If the language cannot be clearly determined, default to English.
        - Do not switch languages based on document names, system context, or prior assistant messages.
        - Official Japanese document names may remain in Japanese when necessary, but please include a translation to the document name.
        If the user asks something clearly unrelated to the PR application or required documents, reply as below following language rules:
        "This assistant only supports Japanese PR application related questions and required documents."
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
