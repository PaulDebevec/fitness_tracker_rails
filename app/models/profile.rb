class Profile < ApplicationRecord
  belongs_to :user
  has_many :check_ins, dependent: :destroy
  scope :recent_first, -> { order(created_at: :desc) }
  validates :display_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :unit_system, presence: true, inclusion: { in: %w[imperial metric] }
  after_initialize :set_defaults, if: :new_record?


  def formatted_unit_system
    case unit_system
    when "imperial"
      "Imperial"
    when "metric"
      "Metric"
    else
      unit_system
    end
  end

  def unit_for(body_part)
    case unit_system
    when "imperial"
      body_part == "weight" ? "lb" : "in"
    when "metric"
      body_part == "weight" ? "kg" : "cm"
    else
      ""
    end
  end

  def latest_check_in
    check_ins.reverse_chronological.first
  end

  def public?
    public_profile
  end
  
  def private?
    !public_profile
  end

  def set_defaults
    self.theme_mode ||= "dark"
    self.theme_color ||= "default"
  end

  def has_any_check_in_photos?
    check_ins.any?(&:has_photos?)
  end
end