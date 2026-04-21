class ReportsController < ApplicationController
  before_action :require_login
  before_action :set_profile
  before_action -> { require_profile_owner_or_admin(@profile) }

  def show
    @report = MeasurementReport.new(
      profile: @profile,
      body_part: params[:body_part],
      timeframe: params[:timeframe],
      change_mode: params[:change_mode]
    )
    
    @body_part = @report.body_part
    @timeframe = @report.timeframe
    @change_mode = @report.change_mode

    respond_to do |format|
      format.html
      format.csv do
        exporter = MeasurementReportCsvExporter.new(report: @report)

        send_data(
          exporter.to_csv,
          filename: csv_filename,
          type: "text/csv"
        )
      end
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:profile_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to profiles_path, alert: "Profile not found."
  end

  def csv_filename
    body_part_segment = @body_part.presence || "all_body_parts"
    "#{@profile.display_name.parameterize}-#{body_part_segment}-#{@timeframe}-report.csv"
  end
end