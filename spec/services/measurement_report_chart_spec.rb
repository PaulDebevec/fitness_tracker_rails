require "rails_helper"

RSpec.describe MeasurementReportChart do
  let(:profile) do
    Profile.create!(display_name: "Paul", unit_system: "imperial")
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

  let(:report) do
    MeasurementReport.new(
      profile: profile,
      body_part: selected_body_part,
      timeframe: selected_timeframe,
      change_mode: selected_change_mode
    )
  end

  let(:chart) { described_class.new(report: report) }

  let(:selected_body_part) { "waist" }
  let(:selected_timeframe) { "all_time" }
  let(:selected_change_mode) { "previous" }

  describe "#chart_data" do
    it "returns date and value pairs for the selected body part" do
      expect(chart.chart_data).to eq([
        [older_check_in.checked_in_on, 36.0],
        [middle_check_in.checked_in_on, 35.0],
        [recent_check_in.checked_in_on, 34.0]
      ])
    end

    it "extends the final point to the chart end date when needed" do
      middle_check_in.measurements.create!(body_part: "chest", value: 41.0)

      chest_report = MeasurementReport.new(
        profile: profile,
        body_part: "chest",
        timeframe: "all_time",
        change_mode: "previous"
      )

      chest_chart = described_class.new(report: chest_report)
      expect(chest_chart.chart_data).to eq([
        [middle_check_in.checked_in_on, 41.0],
        [recent_check_in.checked_in_on, 42.0]
      ])
    end
  end

  describe "#weight_chart_data" do
    let(:selected_body_part) { nil }

    before do
      older_check_in.measurements.create!(body_part: "weight", value: 188.0)
      recent_check_in.measurements.create!(body_part: "weight", value: 185.0)
    end

    it "returns only weight measurements as date/value pairs" do
      expect(chart.weight_chart_data).to eq([
        [older_check_in.checked_in_on, 188.0],
        [recent_check_in.checked_in_on, 185.0]
      ])
    end
  end

  describe "#body_measurement_chart_data" do
    let(:selected_body_part) { nil }

    before do
      recent_check_in.measurements.create!(body_part: "weight", value: 185.0)
    end

    it "returns non-weight body parts as multi-series chart data" do
      expect(chart.body_measurement_chart_data).to include(
        hash_including(
          name: "Waist",
          data: include([older_check_in.checked_in_on, 36.0])
        ),
        hash_including(
          name: "Chest",
          data: include([recent_check_in.checked_in_on, 42.0])
        )
      )
    end

    it "does not include weight in the body measurement chart data" do
      expect(chart.body_measurement_chart_data).not_to include(
        hash_including(name: "Weight")
      )
    end

    it "includes the configured color for each body part series" do
      waist_series = chart.body_measurement_chart_data.find { |series| series[:name] == "Waist" }
      chest_series = chart.body_measurement_chart_data.find { |series| series[:name] == "Chest" }

      expect(waist_series[:color]).to eq("#059669")
      expect(chest_series[:color]).to eq("#dc2626")
    end
  end

  describe "#body_measurement_change_chart_data" do
    let(:selected_body_part) { nil }

    it "returns change since previous check-in by default" do
      waist_series = chart.body_measurement_change_chart_data.find { |series| series[:name] == "Waist" }

      expect(waist_series[:data]).to eq([
        [older_check_in.checked_in_on, 0.0],
        [middle_check_in.checked_in_on, -1.0],
        [recent_check_in.checked_in_on, -1.0]
      ])
    end

    context "when change_mode is starting" do
      let(:selected_change_mode) { "starting" }

      it "returns change since the first check-in in range" do
        waist_series = chart.body_measurement_change_chart_data.find { |series| series[:name] == "Waist" }

        expect(waist_series[:data]).to eq([
          [older_check_in.checked_in_on, 0.0],
          [middle_check_in.checked_in_on, -1.0],
          [recent_check_in.checked_in_on, -2.0]
        ])
      end
    end
  end

  describe "#weight_measurements_present?" do
    let(:selected_body_part) { nil }

    it "returns false when no weight measurements exist" do
      expect(chart.weight_measurements_present?).to be(false)
    end

    it "returns true when weight measurements exist" do
      recent_check_in.measurements.create!(body_part: "weight", value: 185.0)

      expect(chart.weight_measurements_present?).to be(true)
    end
  end

  describe "#body_measurements_present?" do
    let(:selected_body_part) { nil }

    it "returns true when non-weight measurements exist" do
      expect(chart.body_measurements_present?).to be(true)
    end

    it "returns false when only weight measurements exist" do
      Measurement.destroy_all

      older_check_in.measurements.create!(body_part: "weight", value: 188.0)
      recent_check_in.measurements.create!(body_part: "weight", value: 185.0)

      weight_only_report = MeasurementReport.new(
        profile: profile,
        body_part: nil,
        timeframe: "all_time",
        change_mode: "previous"
      )

      weight_only_chart = described_class.new(report: weight_only_report)

      expect(weight_only_chart.body_measurements_present?).to be(false)
    end
  end

  describe "#min_chart_value and #max_chart_value" do
    it "returns chart bounds for the selected body part" do
      expect(chart.min_chart_value).to eq(33)
      expect(chart.max_chart_value).to eq(36.5)
    end
  end

  describe "#min_weight_chart_value and #max_weight_chart_value" do
    let(:selected_body_part) { nil }

    before do
      older_check_in.measurements.create!(body_part: "weight", value: 188.0)
      recent_check_in.measurements.create!(body_part: "weight", value: 185.0)
    end

    it "returns chart bounds for weight data" do
      expect(chart.min_weight_chart_value).to eq(184)
      expect(chart.max_weight_chart_value).to eq(188.5)
    end
  end

  describe "#min_body_measurement_chart_value and #max_body_measurement_chart_value" do
    let(:selected_body_part) { nil }

    it "returns chart bounds for body measurement data" do
      expect(chart.min_body_measurement_chart_value).to eq(33)
      expect(chart.max_body_measurement_chart_value).to eq(42.5)
    end
  end

  describe "#min_body_measurement_change_chart_value and #max_body_measurement_change_chart_value" do
    let(:selected_body_part) { nil }

    it "returns chart bounds for change data including zero" do
      expect(chart.min_body_measurement_change_chart_value).to eq(-2)
      expect(chart.max_body_measurement_change_chart_value).to eq(1)
    end
  end

  describe "#formatted_change_mode" do
    it "returns the formatted label for previous mode" do
      expect(chart.formatted_change_mode).to eq("Since Previous Check-in")
    end

    context "when change_mode is starting" do
      let(:selected_change_mode) { "starting" }

      it "returns the formatted label for starting mode" do
        expect(chart.formatted_change_mode).to eq("Since First Check-in")
      end
    end
  end
end