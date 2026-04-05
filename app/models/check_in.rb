class CheckIn < ApplicationRecord
    belongs_to :profile
    has_many :measurements, dependent: :destroy

    validates :checked_in_on, presence: true, uniqueness: { scope: :profile_id }
    validate :checked_in_on_cannot_be_in_the_future

    def formatted_date
        checked_in_on&.strftime("%B %d, %Y")
    end

    private
    
    def checked_in_on_cannot_be_in_the_future
        return if checked_in_on.blank?
        return unless checked_in_on > Date.current
        errors.add(:checked_in_on, "can't be in the future")
    end
end