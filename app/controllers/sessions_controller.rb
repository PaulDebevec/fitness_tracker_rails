class SessionsController < ApplicationController
  def new
    session[:return_to] = safe_return_to(params[:return_to]) if params[:return_to].present?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      return_to = session[:return_to] || safe_return_to(params[:return_to])

      reset_session
      session[:user_id] = user.id

      redirect_to(return_to || profile_path(user.profile),
                  notice: "Logged in successfully.")
    else
      session[:return_to] = safe_return_to(params[:return_to]) if params[:return_to].present?
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out successfully."
  end

  private

  def safe_return_to(return_to)
    return nil if return_to.blank?

    uri = URI.parse(return_to) rescue nil
    return nil if uri&.host.present?

    return_to
  end
end