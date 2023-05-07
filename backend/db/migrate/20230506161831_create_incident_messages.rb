class CreateIncidentMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :incident_messages do |t|
      t.references :incident, null: false, foreign_key: true
      t.references :subscription, null: false, foreign_key: true
      t.integer :message_id

      t.timestamps
    end
  end
end
