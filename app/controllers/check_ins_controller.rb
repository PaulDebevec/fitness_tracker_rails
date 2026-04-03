class CheckInsController < ApplicationController
  before_action :set_profile
  before_action :set_check_in, only: [:show, :edit, :update, :destroy]

  def index
    @check_ins = @profile.check_ins.order(checked_in_on: :desc)
  end

  def show
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
  end

  def edit
  end

  def update
    if @check_in.update(check_in_params)
      redirect_to profile_check_in_path(@profile, @check_in), notice: "Check-in updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @check_in.destroy
    redirect_to profile_check_ins_path(@profile), notice: "Check-in deleted successfully."
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

  def check_in_params
    params.require(:check_in).permit(:checked_in_on, :notes)
  end
end