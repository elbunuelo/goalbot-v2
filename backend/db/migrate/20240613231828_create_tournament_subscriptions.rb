class CreateTournamentSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :tournament_subscriptions do |t|
      t.string :service
      t.string :conversation_id
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end
  end
end
