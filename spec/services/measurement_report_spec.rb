require "rails_helper"

RSpec.describe MeasurementReport do
  let!(:user) { 
    User.create!(email: "viewer@example.com", 
    password: "supersecure123", 
    password_confirmation: "supersecure123",
    role: "user") 
  }

  let(:profile) do
    Profile.create!(user: user, display_name: "Paul", unit_system: "imperial")
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
  
  describe "all body_parts summary" do
    it "returns measurements for all body parts when no body_part is provided" do
      report = described_class.new(profile: profile, body_part: nil)
    
      expect(report.measurements).to include(older_waist, middle_waist, recent_waist, recent_chest)
    end
    
    it "returns grouped summary data when no body_part is provided" do
      report = described_class.new(profile: profile, body_part: nil)
    
      expect(report.summary.keys).to include("waist", "chest")
      expect(report.summary["waist"][:count]).to eq(3)
      expect(report.summary["chest"][:count]).to eq(1)
    end
  end

  describe "parameter normalization" do
    it "treats an invalid body part as nil" do
      report = described_class.new(
        profile: profile,
        body_part: "forearm",
        timeframe: "all_time"
      )
  
      expect(report.body_part).to be_nil
    end
  
    it "falls back to all_time for an invalid timeframe" do
      report = described_class.new(
        profile: profile,
        body_part: "waist",
        timeframe: "last_500_years"
      )
  
      expect(report.timeframe).to eq("all_time")
    end
  
    it "accepts a valid body part" do
      report = described_class.new(
        profile: profile,
        body_part: "waist",
        timeframe: "all_time"
      )
  
      expect(report.body_part).to eq("waist")
    end
  
    it "accepts a valid timeframe" do
      report = described_class.new(
        profile: profile,
        body_part: "waist",
        timeframe: "30_days"
      )
  
      expect(report.timeframe).to eq("30_days")
    end
  end
end