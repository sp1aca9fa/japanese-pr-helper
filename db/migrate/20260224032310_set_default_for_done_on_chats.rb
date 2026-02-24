class SetDefaultForDoneOnChats < ActiveRecord::Migration[8.1]
  def change
    change_column_default :chats, :done, false
  end
end
