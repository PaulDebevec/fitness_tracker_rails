class ChangeDefaultThemeModeOnProfiles < ActiveRecord::Migration[7.1]
  def change
    change_column_default :profiles, :theme_mode, from: "system", to: "dark"
  end
end
