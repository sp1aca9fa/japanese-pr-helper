class AddSystemPromptToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :system_prompt, :text
  end
end
