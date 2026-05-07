class UserMailerPreview < ActionMailer::Preview
  def email_verification
    UserMailer.with(user: preview_user).email_verification
  end

  def password_reset
    UserMailer.with(user: preview_user).password_reset
  end

  private

  def preview_user
    User.first || User.new(
      email: "preview@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )
  end
end