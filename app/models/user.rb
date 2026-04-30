class User < ApplicationRecord
  has_secure_password

  has_one :profile, dependent: :destroy

  enum :role, { user: "user", admin: "admin" }, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password,
    length: { minimum: 10 },
    if: -> { password.present? }

  validates :role, presence: true

  def email_verified?
    email_verified_at.present?
  end

  def mark_email_as_verified!
    update!(email_verified_at: Time.current)
  end

  def email_verification_token
    signed_id(expires_in: 24.hours, purpose: :email_verification)
  end

  def password_reset_token
    signed_id(expires_in: 30.minutes, purpose: :password_reset)
  end
end