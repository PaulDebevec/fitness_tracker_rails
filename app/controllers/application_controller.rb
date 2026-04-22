class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "You must be logged in to access that page."
  end

  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: "You are not authorized to access that page."
  end

  def require_profile_owner_or_admin(profile)
    return if current_user&.admin?
    return if current_user == profile.user

    redirect_to root_path, alert: "You are not authorized to access that page."
  end

  def can_view_profile?(profile)
    return true if profile.public?
    return true if current_user&.admin?
    return true if current_user == profile.user
  
    false
  end
  
  def require_profile_view_access(profile)
    return if can_view_profile?(profile)
  
    redirect_to root_path, alert: "You are not authorized to view that profile."
  end
end