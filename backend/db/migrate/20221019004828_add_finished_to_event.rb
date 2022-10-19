class AddFinishedToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :finished, :boolean
  end
end
