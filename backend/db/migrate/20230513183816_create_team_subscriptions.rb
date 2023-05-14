class CreateTeamSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :team_subscriptions do |t|
      t.string :conversation_id
      t.string :service
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
