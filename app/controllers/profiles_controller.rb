class ProfilesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  before_action -> { require_profile_view_access(@profile) }, only: [:show]
  before_action -> { require_profile_owner_or_admin(@profile) }, only: [:edit, :update, :destroy]

  def index
    @profiles =
      if current_user&.admin?
        Profile.recent_first
      elsif current_user.present?
        Profile
          .where("public_profile = ? OR user_id = ?", true, current_user.id)
          .recent_first
      else
        Profile.where(public_profile: true).recent_first
      end
  end

  def show
    @check_ins = @profile.check_ins.reverse_chronological
    @photo_type = params[:photo_type].presence || "front_photo"
    @photo_timeline = ProfilePhotoTimeline.new(profile: @profile, photo_type: @photo_type)
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @profile.destroy
    redirect_to profiles_path, notice: "Profile deleted successfully."
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to profiles_path, alert: "Profile not found."
  end

  def profile_params
    params.require(:profile).permit(
      :display_name,
      :unit_system,
      :public_profile
    )
  end
end