class RenameDefaultUnitToUnitSystemInProfiles < ActiveRecord::Migration[7.1]
  def change
    rename_column :profiles, :default_unit, :unit_system
    change_column_default :profiles, :unit_system, "imperial"
  end
end