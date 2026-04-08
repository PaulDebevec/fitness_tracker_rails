class ReportsController < ApplicationController
    before_action :set_profile
  
    def show
      @body_part = params[:body_part].presence
      @timeframe = params[:timeframe].presence || "all_time"
  
      @report = MeasurementReport.new(
        profile: @profile,
        body_part: @body_part,
        timeframe: @timeframe
      )
    end
  
    private
  
    def set_profile
      @profile = Profile.find(params[:profile_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to profiles_path, alert: "Profile not found."
    end
end