class Profile < ApplicationRecord
    validates :display_name, presence: true, length: { minimum: 2, maximum: 50 }
    validates :default_unit, presence: true, inclusion: { in: %w[in cm] }
end
