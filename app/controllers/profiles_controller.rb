class ProfilesController < ApplicationController
  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)
    if @profile.save
      redirect_to profile_check_ins_path(@profile), notice: "Profile created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:display_name, :default_unit)
  end
end
