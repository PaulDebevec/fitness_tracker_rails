class PasswordResetsController < ApplicationController
    before_action :redirect_if_logged_in, only: [:new, :create]
    before_action :set_user_from_token, only: [:edit, :update]
  
    def new
    end
  
    def create
      user = User.find_by(email: params[:email].to_s.strip.downcase)
  
      UserMailer.with(user: user).password_reset.deliver_later if user
  
      redirect_to login_path, notice: "If that email exists, password reset instructions have been sent."
    end
  
    def edit
    end
  
    def update
      if @user.update(password_params)
        redirect_to login_path, notice: "Your password has been reset. Please log in."
      else
        render :edit, status: :unprocessable_content
      end
    end
  
    private
  
    def set_user_from_token
      @user = User.find_signed!(params[:token], purpose: :password_reset)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_reset_path, alert: "Password reset link is invalid or has expired."
    end
  
    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end