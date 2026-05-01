require "rails_helper"
require "securerandom"

RSpec.describe "PasswordResets", type: :request do
  include ActiveJob::TestHelper

  let(:user) do
    User.create!(
      email: "paul-#{SecureRandom.hex(4)}@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )
  end

  describe "GET /password_resets/new" do
    it "renders the forgot password form" do
      get new_password_reset_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Forgot Password")
    end
  end

  describe "POST /password_resets" do
    before do
      ActionMailer::Base.deliveries.clear
      clear_enqueued_jobs
    end

    it "sends reset instructions when the email exists" do
      perform_enqueued_jobs do
        post password_resets_path, params: { email: user.email }
      end

      expect(response).to redirect_to(login_path)
      follow_redirect!

      expect(response.body).to include("If that email exists, password reset instructions have been sent.")
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "does not reveal whether the email exists" do
      perform_enqueued_jobs do
        post password_resets_path, params: { email: "missing-#{SecureRandom.hex(4)}@example.com" }
      end

      expect(response).to redirect_to(login_path)
      follow_redirect!

      expect(response.body).to include("If that email exists, password reset instructions have been sent.")
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  describe "GET /password_resets/:token/edit" do
    it "renders the reset password form with a valid token" do
      get edit_password_reset_path(user.password_reset_token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reset Password")
    end

    it "redirects with an invalid token" do
      get edit_password_reset_path("invalid-token")

      expect(response).to redirect_to(new_password_reset_path)
      follow_redirect!

      expect(response.body).to include("Password reset link is invalid or has expired.")
    end
  end

  describe "PATCH /password_resets/:token" do
    it "updates the user password with a valid token" do
      patch password_reset_path(user.password_reset_token), params: {
        user: {
          password: "newsecure123",
          password_confirmation: "newsecure123"
        }
      }

      expect(response).to redirect_to(login_path)
      expect(user.reload.authenticate("newsecure123")).to eq(user)
    end

    it "renders errors when the password is invalid" do
      patch password_reset_path(user.password_reset_token), params: {
        user: {
          password: "short",
          password_confirmation: "short"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Password is too short")
    end

    it "redirects with an invalid token" do
      patch password_reset_path("invalid-token"), params: {
        user: {
          password: "newsecure123",
          password_confirmation: "newsecure123"
        }
      }

      expect(response).to redirect_to(new_password_reset_path)
      expect(user.reload.authenticate("supersecure123")).to eq(user)
    end
  end
end