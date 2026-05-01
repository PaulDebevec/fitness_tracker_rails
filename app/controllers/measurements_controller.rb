class MeasurementsController < ApplicationController
    before_action :require_login
    before_action :set_profile
    before_action :set_check_in
    before_action :set_measurement, only: [:show, :edit, :update, :destroy]
    before_action -> { require_profile_owner_or_admin(@profile) }, only: [:create, :edit, :update, :destroy]
    before_action :require_verified_email
  
    def index
      @measurements = @check_in.measurements.ordered_by_body_part
    end
  
    def show
    end
  
    def new
      @measurement = @check_in.measurements.new
    end
  
    def create
      @measurement = @check_in.measurements.new(measurement_params)
  
      if @measurement.save
        redirect_to profile_check_in_path(@profile, @check_in), notice: "Measurement created successfully."
      else
        render :new, status: :unprocessable_content
      end
    end
  
    def edit
    end
  
    def update
      if @measurement.update(measurement_params)
        redirect_to profile_check_in_measurement_path(@profile, @check_in, @measurement), notice: "Measurement updated successfully."
      else
        render :edit, status: :unprocessable_content
      end
    end
  
    def destroy
      @measurement.destroy
      redirect_to profile_check_in_measurements_path(@profile, @check_in), notice: "Measurement deleted successfully."
    end
  
    private
  
    def set_profile
      @profile = Profile.find(params[:profile_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to profiles_path, alert: "Profile not found."
    end
  
    def set_check_in
      @check_in = @profile.check_ins.find(params[:check_in_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to profile_check_ins_path(@profile), alert: "Check-in not found."
    end
  
    def set_measurement
      @measurement = @check_in.measurements.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to profile_check_in_measurements_path(@profile, @check_in), alert: "Measurement not found."
    end
  
    def measurement_params
      params.require(:measurement).permit(:body_part, :value, :body_part_photo)
    end
  end