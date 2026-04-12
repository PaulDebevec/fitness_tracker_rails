require "rails_helper"

RSpec.describe MeasurementReportCsvExporter do
  let(:profile) do
    Profile.create!(display_name: "Paul", unit_system: "imperial")
  end

  let!(:older_check_in) do
    profile.check_ins.create!(
      checked_in_on: Date.current - 30.days,
      notes: "Older check-in"
    )
  end

  let!(:recent_check_in) do
    profile.check_ins.create!(
      checked_in_on: Date.current - 7.days,
      notes: "Recent check-in"
    )
  end

  let!(:older_waist) do
    older_check_in.measurements.create!(
      body_part: "waist",
      value: 36.0
    )
  end

  let!(:recent_waist) do
    recent_check_in.measurements.create!(
      body_part: "waist",
      value: 34.5
    )
  end

  it "exports the report as csv" do
    report = MeasurementReport.new(
      profile: profile,
      body_part: "waist",
      timeframe: "all_time"
    )

    exporter = described_class.new(report: report)
    csv_output = exporter.to_csv

    expect(csv_output).to include("profile,body_part,check_in_date,value,timeframe")
    expect(csv_output).to include("Paul,waist")
    expect(csv_output).to include(older_check_in.checked_in_on.to_s)
    expect(csv_output).to include(recent_check_in.checked_in_on.to_s)
    expect(csv_output).to include("36.0")
    expect(csv_output).to include("34.5")
    expect(csv_output).to include("all_time")
  end

  it "exports all matching body parts when no body part is selected" do
    recent_check_in.measurements.create!(
      body_part: "chest",
      value: 42.0
    )

    report = MeasurementReport.new(
      profile: profile,
      body_part: nil,
      timeframe: "all_time"
    )

    exporter = described_class.new(report: report)
    csv_output = exporter.to_csv

    expect(csv_output).to include("waist")
    expect(csv_output).to include("chest")
  end
end