require "rails_helper"

RSpec.describe "Reports", type: :request do
  describe "GET /profiles/:profile_id/report" do
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
        checked_in_on: Date.current - 38.days,
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

    let!(:recent_chest) do
      recent_check_in.measurements.create!(
        body_part: "chest",
        value: 42.0
      )
    end

    it "returns http success for html" do
      get profile_report_path(profile)
      expect(response).to have_http_status(:ok)
    end

    it "returns csv data for a selected body part" do
      get profile_report_path(profile, format: :csv), params: {
        body_part: "waist",
        timeframe: "all_time"
      }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.body).to include("profile,body_part,check_in_date,value,timeframe")
      expect(response.body).to include("Paul,waist")
      expect(response.body).to include(older_check_in.checked_in_on.to_s)
      expect(response.body).to include(recent_check_in.checked_in_on.to_s)
      expect(response.body).to include("36.0")
      expect(response.body).to include("34.5")
      expect(response.body).not_to include("chest")
    end

    it "returns csv data for all body parts when none is selected" do
      get profile_report_path(profile, format: :csv), params: {
        timeframe: "all_time"
      }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.body).to include("profile,body_part,check_in_date,value,timeframe")
      expect(response.body).to include("waist")
      expect(response.body).to include("chest")
      expect(response.body).to include("36.0")
      expect(response.body).to include("34.5")
      expect(response.body).to include("42.0")
    end

    it "filters csv data by timeframe" do
      get profile_report_path(profile, format: :csv), params: {
        body_part: "waist",
        timeframe: "30_days"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("34.5")
      expect(response.body).not_to include("36.0")
    end

    it "sets a csv filename" do
      get profile_report_path(profile, format: :csv), params: {
        body_part: "waist",
        timeframe: "30_days"
      }

      expect(response.headers["Content-Disposition"]).to include("paul-waist-30_days-report.csv")
    end

    it "redirects when the profile does not exist" do
      get "/profiles/999999/report"
      expect(response).to redirect_to(profiles_path)
    end
  end
end