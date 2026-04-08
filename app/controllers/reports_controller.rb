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