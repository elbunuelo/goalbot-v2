class AddTournamentToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :tournament, :string
  end
end
