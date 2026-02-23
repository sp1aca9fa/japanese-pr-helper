class CreateChats < ActiveRecord::Migration[8.1]
  def change
    create_table :chats do |t|
      t.string :title
      t.boolean :done
      t.references :user_application, null: false, foreign_key: true

      t.timestamps
    end
  end
end
