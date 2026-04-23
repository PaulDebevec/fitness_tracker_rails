require "rails_helper"

RSpec.describe "Profiles", type: :request do
  before(:each) do
    @private_owner = User.create!(
      email: "private_owner@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @public_owner = User.create!(
      email: "public_owner@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @non_owner = User.create!(
      email: "viewer@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @admin = User.create!(
      email: "admin@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "admin"
    )

    @non_owner_profile = Profile.create!(
      user: @non_owner,
      display_name: "Non-Owner",
      unit_system: "imperial",
      public_profile: false
    )

    @admin_profile = Profile.create!(
      user: @admin,
      display_name: "Admin",
      unit_system: "imperial",
      public_profile: false
    )

    @private_profile = Profile.create!(
      user: @private_owner,
      display_name: "PrivateOwn",
      unit_system: "imperial",
      public_profile: false
    )

    @public_profile = Profile.create!(
      user: @public_owner,
      display_name: "PublicOwn",
      unit_system: "imperial",
      public_profile: true
    )
  end

  describe "GET /profiles" do
    it "allows guests to see public profiles only" do
      get profiles_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("PublicOwn")
      expect(response.body).not_to include("PrivateOwn")
      expect(response.body).not_to include("Admin")
    end

    it "allows a logged-in private user to see public profiles and their own private profile" do
      log_in_as(@private_owner)

      get profiles_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("PublicOwn")
      expect(response.body).to include("PrivateOwn")
    end

    it "allows an admin to see all profiles" do
      log_in_as(@admin)

      get profiles_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("PublicOwn")
      expect(response.body).to include("PrivateOwn")
      expect(response.body).to include("Non-Owner")
    end
  end

  describe "GET /profiles/:id" do
    it "allows guests to view a public profile" do
      get profile_path(@public_profile)

      expect(response).to have_http_status(:ok)
    end

    it "redirects guests away from a private profile" do
      get profile_path(@private_profile)

      expect(response).to redirect_to(root_path)
    end

    it "allows the owner to view their private profile" do
      log_in_as(@private_owner)

      get profile_path(@private_profile)

      expect(response).to have_http_status(:ok)
    end

    it "allows an admin to view a private profile" do
      log_in_as(@admin)

      get profile_path(@private_profile)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /profiles/:id" do
    it "redirects guests to login" do
      patch profile_path(@public_profile), params: {
        profile: {
          display_name: "Updated Name"
        }
      }

      expect(response).to redirect_to(login_path)
    end

    it "allows the owner to update their profile" do
      log_in_as(@public_owner)

      patch profile_path(@public_profile), params: {
        profile: {
          display_name: "Updated Name"
        }
      }

      expect(response).to redirect_to(profile_path(@public_profile))
      expect(@public_profile.reload.display_name).to eq("Updated Name")
    end

    it "redirects a non-owner user" do
      log_in_as(@non_owner)

      patch profile_path(@public_profile), params: {
        profile: {
          display_name: "Hacked Name"
        }
      }

      expect(response).to redirect_to(root_path)
      expect(@public_profile.reload.display_name).to eq("PublicOwn")
    end
  end
end