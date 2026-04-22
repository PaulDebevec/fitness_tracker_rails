require "rails_helper"

RSpec.describe "Profiles", type: :request do
  describe "POST /profiles" do
    context "with valid params" do
      it "creates a profile and redirects to check-ins index" do
        expect {
          post profiles_path, params: {
            profile: {
              display_name: "Paul",
              unit_system: "imperial"
            }
          }
        }.to change(Profile, :count).by(1)

        profile = Profile.last
        expect(response).to redirect_to(profile_path(profile))
      end
    end

    context "with invalid params" do
      it "does not create a profile" do
        expect {
          post profiles_path, params: {
            profile: {
              display_name: "",
              unit_system: ""
            }
          }
        }.not_to change(Profile, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /profiles" do
    it "redirects when deleting a non-existent profile" do
      delete "/profiles/999999"

      expect(response).to redirect_to(profiles_path)
      follow_redirect!

      expect(response.body).to include("Profile not found.")
    end
  end
end