class EmailVerificationsController < ApplicationController
    before_action :require_login, only: [:create]
  
    def create
      UserMailer.with(user: current_user).email_verification.deliver_later
    
      redirect_to edit_settings_path, notice: "Verification email sent. Please check your inbox."
    end
  
    def show
      user = User.find_signed!(params[:token], purpose: :email_verification)
  
      user.mark_email_as_verified!
  
      redirect_to login_path, notice: "Your email has been verified. Please log in."
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to login_path, alert: "Verification link is invalid or has expired."
    end
  end