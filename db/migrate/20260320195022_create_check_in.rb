class CreateCheckIn < ActiveRecord::Migration[7.1]
  def change
    create_table :check_ins do |t|
      t.references :profile, null: false, foreign_key: true
      t.date :checked_in_on
      t.text :notes

      t.timestamps
    end
  end
end
