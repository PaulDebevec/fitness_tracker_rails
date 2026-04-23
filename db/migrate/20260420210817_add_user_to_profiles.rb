class AddUserToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_reference :profiles, :user, null: false, foreign_key: true, index: { unique: true }
  end
end