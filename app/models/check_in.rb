class CheckIn < ApplicationRecord
    belongs_to :profile
    has_many :measurements, dependent: :destroy

    has_one_attached :front_photo
    has_one_attached :back_photo
    has_one_attached :side_photo

    scope :chronological, -> { order(checked_in_on: :asc) }
    scope :reverse_chronological, -> { order(checked_in_on: :desc) }

    validates :checked_in_on, presence: true
    validates :checked_in_on, uniqueness: { scope: :profile_id }
    validate :checked_in_on_cannot_be_in_the_future

    def formatted_date
        checked_in_on&.strftime("%B %d, %Y")
    end

    def has_photos?
        front_photo.attached? || back_photo.attached? || side_photo.attached?
    end

    private

    def checked_in_on_cannot_be_in_the_future
        return if checked_in_on.blank?
        return unless checked_in_on > Date.current

        errors.add(:checked_in_on, "can't be in the future")
    end
end