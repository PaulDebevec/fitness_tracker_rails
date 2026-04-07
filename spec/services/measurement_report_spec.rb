require "rails_helper"

RSpec.describe MeasurementReport do
  let(:profile) do
    Profile.create!(display_name: "Paul", default_unit: "in")
  end

  let!(:older_check_in) do
    profile.check_ins.create!(
      checked_in_on: Date.current - 60.days,
      notes: "Older check-in"
    )
  end

  let!(:middle_check_in) do
    profile.check_ins.create!(
      checked_in_on: Date.current - 30.days,
      notes: "Middle check-in"
    )
  end

  let!(:recent_check_in) do
    profile.check_ins.create!(
      checked_in_on: Date.current - 7.days,
      notes: "Recent check-in"
    )
  end

  let!(:older_waist) do
    older_check_in.measurements.create!(body_part: "waist", value: 36.0)
  end

  let!(:middle_waist) do
    middle_check_in.measurements.create!(body_part: "waist", value: 35.0)
  end

  let!(:recent_waist) do
    recent_check_in.measurements.create!(body_part: "waist", value: 34.0)
  end

  let!(:recent_chest) do
    recent_check_in.measurements.create!(body_part: "chest", value: 42.0)
  end

  describe "#measurements" do
    it "returns measurements for the given body part in ascending date order" do
      report = described_class.new(profile: profile, body_part: "waist")

      expect(report.measurements).to eq([older_waist, middle_waist, recent_waist])
    end

    it "does not include other body parts" do
      report = described_class.new(profile: profile, body_part: "waist")

      expect(report.measurements).not_to include(recent_chest)
    end
  end

  describe "#chart_data" do
    it "returns date and value pairs" do
      report = described_class.new(profile: profile, body_part: "waist")

      expect(report.chart_data).to eq([
        { date: older_check_in.checked_in_on, value: 36.0 },
        { date: middle_check_in.checked_in_on, value: 35.0 },
        { date: recent_check_in.checked_in_on, value: 34.0 }
      ])
    end
  end

  describe "#summary" do
    it "returns summary statistics for the filtered measurements" do
      report = described_class.new(profile: profile, body_part: "waist")

      expect(report.summary).to include(
        body_part: "waist",
        timeframe: "all_time",
        count: 3,
        start_date: older_check_in.checked_in_on,
        end_date: recent_check_in.checked_in_on,
        starting_value: 36.0,
        ending_value: 34.0,
        change: -2.0,
        min: 34.0,
        max: 36.0,
        average: 35.0
      )
    end

    it "returns an empty summary when there are no matching measurements" do
      report = described_class.new(profile: profile, body_part: "hips")

      expect(report.summary).to include(
        body_part: "hips",
        timeframe: "all_time",
        count: 0,
        start_date: nil,
        end_date: nil,
        starting_value: nil,
        ending_value: nil,
        change: nil,
        min: nil,
        max: nil,
        average: nil
      )
    end
  end

  describe "timeframe filtering" do
    it "filters to the last 30 days" do
      report = described_class.new(profile: profile, body_part: "waist", timeframe: "30_days")

      expect(report.measurements).to eq([middle_waist, recent_waist])
    end

    it "returns all measurements for all_time" do
      report = described_class.new(profile: profile, body_part: "waist", timeframe: "all_time")

      expect(report.measurements).to eq([older_waist, middle_waist, recent_waist])
    end
  end
end