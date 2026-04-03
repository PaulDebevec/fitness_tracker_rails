class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)
    if @profile.save
      redirect_to profile_path(@profile), notice: "Profile created successfully"
    else
      flash.now[:alert] = 'Profile could not be created.'
      render :new, status: :unprocessable_content
    end
  end

  def show
    # @profile = Profile.find(params[:id])
    @check_ins = @profile.check_ins.order(checked_in_on: :desc)
  end

  def index
    @profiles = Profile.all
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
    flash[:alert] = "Profile not found."
    redirect_to profiles_path
  end

  def profile_params
    params.require(:profile).permit(:display_name, :default_unit)
  end
end
