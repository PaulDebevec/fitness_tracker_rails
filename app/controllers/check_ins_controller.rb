class CheckInsController < ApplicationController
  before_action :set_profile
  before_action :set_check_in, only: [:show, :edit, :update, :destroy, :remove_photo]

  def index
    @check_ins = @profile.check_ins.reverse_chronological
  end

  def show
    @measurements = @check_in.measurements.ordered_by_body_part
  end

  def new
    @check_in = @profile.check_ins.new
  end

  def create
    @check_in = @profile.check_ins.new(check_in_params)

    if @check_in.save
      redirect_to profile_check_in_path(@profile, @check_in), notice: "Check-in created successfully."
    else
      render :new, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    @check_in = @profile.check_ins.new(check_in_form_params)
    @check_in.errors.add(:checked_in_on, "has already been taken for this profile")
    flash.now[:alert] = "Please re-select any photos before submitting again."
    render :new, status: :unprocessable_content
  end

  def update
    if @check_in.update(check_in_params)
      redirect_to profile_check_in_path(@profile, @check_in), notice: "Check-in updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    @check_in.assign_attributes(check_in_form_params)
    @check_in.errors.add(:checked_in_on, "has already been taken for this profile")
    flash.now[:alert] = "Please re-select any replacement photos before submitting again."
    render :edit, status: :unprocessable_content
  end

  def edit
  end

  def destroy
    @check_in.destroy
    redirect_to profile_check_ins_path(@profile), notice: "Check-in deleted successfully."
  end

  def remove_photo
    photo_name = params[:photo_name]
  
    unless removable_photo_names.include?(photo_name)
      redirect_to profile_check_in_path(@profile, @check_in), alert: "Invalid photo selection."
      return
    end
  
    attachment = @check_in.public_send(photo_name)
  
    if attachment.attached?
      attachment.purge
      redirect_to profile_check_in_path(@profile, @check_in), notice: "#{photo_name.humanize} removed successfully."
    else
      redirect_to profile_check_in_path(@profile, @check_in), alert: "Photo not found."
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:profile_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to profiles_path, alert: "Profile not found."
  end

  def set_check_in
    @check_in = @profile.check_ins.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to profile_check_ins_path(@profile), alert: "Check-in not found."
  end

  def removable_photo_names
    %w[
      front_photo
      back_photo
      profile_photo
    ]
  end

  def check_in_params
    params.require(:check_in).permit(
      :checked_in_on,
      :notes,
      :front_photo,
      :back_photo,
      :profile_photo
    )
  end
  
  def check_in_form_params
    params.require(:check_in).permit(
      :checked_in_on,
      :notes
    )
  end
end