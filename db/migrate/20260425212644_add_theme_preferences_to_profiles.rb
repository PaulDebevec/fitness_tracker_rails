class AddThemePreferencesToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :theme_mode, :string
    add_column :profiles, :theme_color, :string
  end
end
