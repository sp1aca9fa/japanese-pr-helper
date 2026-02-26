class AddPinToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :pin, :boolean, default: false, null: false
  end
end
