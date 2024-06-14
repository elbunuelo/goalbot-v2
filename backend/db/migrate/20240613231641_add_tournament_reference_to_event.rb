class AddTournamentReferenceToEvent < ActiveRecord::Migration[7.0]
  def change
    add_reference :events, :tournament, foreign_key: true
  end
end
