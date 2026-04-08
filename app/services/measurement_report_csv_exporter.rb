require "csv"

class MeasurementReportCsvExporter
  attr_reader :report

  def initialize(report:)
    @report = report
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["profile", "body_part", "check_in_date", "value", "timeframe"]

      report.measurements.each do |measurement|
        csv << [
          report.profile.display_name,
          measurement.body_part,
          measurement.check_in.checked_in_on,
          measurement.value,
          report.timeframe
        ]
      end
    end
  end
end