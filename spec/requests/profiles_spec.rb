require "rails_helper"

RSpec.describe "Profiles", type: :request do
  describe "GET /profiles/new" do
    it "returns a success response" do
      get new_profile_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /profiles" do
    context "with valid params" do
      it "creates a profile and redirects to check-ins index" do
        expect {
          post profiles_path, params: {
            profile: {
              display_name: "Paul",
              default_unit: "in"
            }
          }
        }.to change(Profile, :count).by(1)

        profile = Profile.last
        expect(response).to redirect_to(profile_check_ins_path(profile))
      end
    end

    context "with invalid params" do
      it "does not create a profile" do
        expect {
          post profiles_path, params: {
            profile: {
              display_name: "",
              default_unit: ""
            }
          }
        }.not_to change(Profile, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end