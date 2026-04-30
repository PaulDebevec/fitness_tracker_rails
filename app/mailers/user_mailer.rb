class UserMailer < ApplicationMailer
  def email_verification
    @user = params[:user]
    @verification_url = verify_email_url(@user.email_verification_token)

    mail(to: @user.email, subject: "Verify your BodiMetrix email")
  end

  def password_reset
    @user = params[:user]
    @reset_url = edit_password_reset_url(token: @user.password_reset_token)

    mail(to: @user.email, subject: "Reset your BodiMetrix password")
  end
end