class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.string :display_name
      t.string :default_unit, default: 'in'

      t.timestamps
    end
  end
end
