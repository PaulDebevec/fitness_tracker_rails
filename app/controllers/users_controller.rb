class UsersController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]
  before_action :require_login, only: [:destroy]
  before_action :set_user, only: [:destroy]
  before_action :require_user_owner_or_admin, only: [:destroy]

  def new
    @user = User.new
    @profile = Profile.new
  end

  def create
    @user = User.new(user_params)
    @profile = @user.build_profile(profile_params)

    ActiveRecord::Base.transaction do
      @user.save!
      @profile.save!
    end

    reset_session
    session[:user_id] = @user.id

    redirect_to profile_path(@user.profile),
      notice: "Account created successfully.",
      flash: { track_signup: true }
      
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  def destroy
    unless delete_confirmation_valid?
      redirect_to edit_settings_path, alert: "Please type DELETE to confirm account deletion."
      return
    end
  
    deleting_current_user = (@user == current_user)
  
    @user.destroy
    reset_session if deleting_current_user
  
    redirect_to root_path, notice: "Account deleted successfully."
  end

  private

  def delete_confirmation_valid?
    params[:delete_confirmation].to_s.casecmp("delete").zero?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def require_user_owner_or_admin
    return if current_user&.admin?
    return if current_user == @user

    redirect_to root_path, alert: "You are not authorized to perform that action."
  end

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation
    )
  end

  def profile_params
    params.require(:profile).permit(
      :display_name,
      :unit_system,
      :public_profile
    )
  end
end