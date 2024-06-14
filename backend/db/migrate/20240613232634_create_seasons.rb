class CreateSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :seasons do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :year
      t.string :ss_id
      t.string :name

      t.timestamps
    end
  end
end
