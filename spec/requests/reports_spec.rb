require "rails_helper"

RSpec.describe "Reports", type: :request do
  describe "GET /profiles/:profile_id/report" do
    let(:profile) do
      Profile.create!(display_name: "Paul", default_unit: "in")
    end

    it "returns http success" do
      get profile_report_path(profile)

      expect(response).to have_http_status(:ok)
    end

    it "returns http success with a selected body part and timeframe" do
      get profile_report_path(profile), params: {
        body_part: "waist",
        timeframe: "30_days"
      }

      expect(response).to have_http_status(:ok)
    end

    it "redirects when the profile does not exist" do
      get "/profiles/999999/report"

      expect(response).to redirect_to(profiles_path)
    end
  end
end