require "rails_helper"
require "securerandom"

RSpec.describe "EmailVerifications", type: :request do
  include ActiveJob::TestHelper

  let(:user) do
    User.create!(
      email: "paul-#{SecureRandom.hex(4)}@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )
  end

  let(:profile) do
    Profile.create!(
      user: user,
      display_name: "Paul",
      unit_system: "imperial"
    )
  end

  before do
    profile
    ActionMailer::Base.deliveries.clear
    clear_enqueued_jobs
  end

  describe "POST /email_verification" do
    it "sends a verification email for the logged-in user" do
      post login_path, params: {
        email: user.email,
        password: "supersecure123"
      }

      perform_enqueued_jobs do
        post email_verification_path
      end

      expect(response).to redirect_to(edit_settings_path)
      follow_redirect!

      expect(response.body).to include("Verification email sent. Please check your inbox.")
      expect(ActionMailer::Base.deliveries.count).to eq(1)

      email = ActionMailer::Base.deliveries.last

      expect(email.to).to eq([user.email])
      expect(email.subject).to eq("Verify your BodiMetrix email")
    end

    it "redirects logged-out users to login" do
      post email_verification_path

      expect(response).to redirect_to(login_path)
      follow_redirect!

      expect(response.body).to include("You must be logged in to access that page.")
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  describe "GET /email_verification/:token" do
    it "verifies a user email with a valid token" do
      get verify_email_path(user.email_verification_token)

      expect(response).to redirect_to(login_path)
      follow_redirect!

      expect(response.body).to include("Your email has been verified. Please log in.")
      expect(user.reload.email_verified?).to be(true)
    end

    it "redirects with an invalid token" do
      get verify_email_path("invalid-token")

      expect(response).to redirect_to(login_path)
      follow_redirect!

      expect(response.body).to include("Verification link is invalid or has expired.")
      expect(user.reload.email_verified?).to be(false)
    end
  end
end