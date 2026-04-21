class User < ApplicationRecord
    has_secure_password
  
    has_one :profile, dependent: :destroy
  
    enum :role, { user: "user", admin: "admin" }, validate: true
  
    normalizes :email, with: ->(email) { email.strip.downcase }
  
    validates :email,
              presence: true,
              uniqueness: true,
              format: { with: URI::MailTo::EMAIL_REGEXP }
  
    validates :password, length: { minimum: 10 }, if: -> { password.present? }
  end