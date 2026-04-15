class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  def index
    @profiles = Profile.recent_first
  end

  def show
    @check_ins = @profile.check_ins.reverse_chronological
    @photo_type = params[:photo_type].presence || "front_photo"
    @photo_timeline = ProfilePhotoTimeline.new(profile: @profile, photo_type: @photo_type)
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      redirect_to profile_path(@profile), notice: "Profile created successfully."
    else
      render :new, status: :unprocessable_content
    end
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
    params.require(:profile).permit(:display_name, :unit_system)
  end
end