class CreateTournamentAliases < ActiveRecord::Migration[7.0]
  def change
    create_table :tournament_aliases do |t|
      t.string :alias
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end
  end
end
