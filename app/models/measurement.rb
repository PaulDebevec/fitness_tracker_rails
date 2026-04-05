class Measurement < ApplicationRecord
  BODY_PARTS = %w[
    weight
    chest
    waist
    hips
    shoulders
    bicep_left
    bicep_right
    thigh_left
    thigh_right
  ].freeze

  belongs_to :check_in

  validates :body_part, presence: true, inclusion: { in: BODY_PARTS }
  validates :value, presence: true, numericality: { greater_than: 0 }
end