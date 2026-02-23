class CreateUserApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :user_applications do |t|
      t.string :title
      t.references :user, null: false, foreign_key: true
      t.references :application_journey, null: false, foreign_key: true

      t.timestamps
    end
  end
end
