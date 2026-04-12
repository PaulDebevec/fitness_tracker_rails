class NormalizeExistingProfileUnitSystems < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      UPDATE profiles SET unit_system = 'imperial' WHERE unit_system = 'in';
      UPDATE profiles SET unit_system = 'metric' WHERE unit_system = 'cm';
    SQL
  end
end