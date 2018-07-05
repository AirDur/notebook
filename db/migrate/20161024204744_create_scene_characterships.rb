class CreateSceneCharacterships < ActiveRecord::Migration[4.2]
  def change
    create_table :scene_characterships do |t|
      t.integer :user_id
      t.integer :scene_id
      t.integer :scene_character_id
    end
  end
end
