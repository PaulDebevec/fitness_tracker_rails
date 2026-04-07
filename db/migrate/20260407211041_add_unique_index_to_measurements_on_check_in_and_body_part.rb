class AddUniqueIndexToMeasurementsOnCheckInAndBodyPart < ActiveRecord::Migration[7.1]
  def change
    add_index :measurements, [:check_in_id, :body_part], unique: true
  end
end