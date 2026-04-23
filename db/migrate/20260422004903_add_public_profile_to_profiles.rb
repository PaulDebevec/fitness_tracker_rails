class AddPublicProfileToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :public_profile, :boolean, null: false, default: true
  end
end