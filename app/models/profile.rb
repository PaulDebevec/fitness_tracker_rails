class Profile < ApplicationRecord
  has_many :check_ins, dependent: :destroy

  validates :display_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :default_unit, presence: true, inclusion: { in: %w[in cm] }

  def formatted_default_unit
    case default_unit
    when "in"
      "Inches"
    when "cm"
      "Centimeters"
    else
      default_unit
    end
  end
end