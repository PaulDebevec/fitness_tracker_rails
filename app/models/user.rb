class User < ApplicationRecord
    has_secure_password
  
    enum :role, { user: "user", admin: "admin" }, validate: true
  
    normalizes :email, with: ->(email) { email.strip.downcase }
  
    validates :email,
              presence: true,
              uniqueness: true,
              format: { with: URI::MailTo::EMAIL_REGEXP }
  
    validates :password, length: { minimum: 12 }, if: -> { password.present? }
  end