class AddUniqueIndexToCheckIns < ActiveRecord::Migration[7.1]
  def change
    add_index :check_ins, %i[profile_id checked_in_on], unique: true
  end
end
