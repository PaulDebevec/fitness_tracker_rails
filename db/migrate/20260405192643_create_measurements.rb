class CreateMeasurements < ActiveRecord::Migration[7.1]
  def change
    create_table :measurements do |t|
      t.references :check_in, null: false, foreign_key: true
      t.string :body_part
      t.decimal :value

      t.timestamps
    end
  end
end
