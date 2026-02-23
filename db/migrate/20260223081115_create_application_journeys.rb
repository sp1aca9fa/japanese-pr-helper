class CreateApplicationJourneys < ActiveRecord::Migration[8.1]
  def change
    create_table :application_journeys do |t|
      t.integer :application_road
      t.text :system_prompt
      t.text :description

      t.timestamps
    end
  end
end
