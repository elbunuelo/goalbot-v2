class CreateTournaments < ActiveRecord::Migration[7.0]
  def change
    create_table :tournaments do |t|
      t.string :name
      t.string :slug
      t.string :ss_id

      t.timestamps
    end
  end
end
