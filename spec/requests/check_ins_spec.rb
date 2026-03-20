require "rails_helper"

RSpec.describe "CheckIns", type: :request do
  describe "GET /profiles/:profile_id/check_ins" do
    it "returns http success" do
      profile = Profile.create!(display_name: "Paul", default_unit: "in")

      get profile_check_ins_path(profile)

      expect(response).to have_http_status(:ok)
    end
  end
end