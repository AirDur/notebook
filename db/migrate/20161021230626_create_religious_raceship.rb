class CreateReligiousRaceship < ActiveRecord::Migration[4.2]
  def change
    create_table :religious_raceships do |t|
      t.integer :religion_id
      t.integer :race_id
      t.integer :user_id
    end
  end
end
