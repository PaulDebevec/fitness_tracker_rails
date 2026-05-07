require "rails_helper"
require "securerandom"

RSpec.describe "Email verification", type: :feature do
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

  it "sends a verification email from the settings page" do
    log_in_with(email: user.email)

    visit edit_settings_path

    perform_enqueued_jobs do
      page.driver.submit :post, email_verification_path, {}
    end

    expect(page).to have_content("Verification email sent. Please check your inbox.")
    expect(ActionMailer::Base.deliveries.count).to eq(1)

    email = ActionMailer::Base.deliveries.last

    expect(email.to).to eq([user.email])
    expect(email.subject).to eq("Verify your BodiMetrix email")
  end

  it "verifies the user email with a valid token" do
    token = user.email_verification_token

    visit verify_email_path(token)

    expect(current_path).to eq(login_path)
    expect(page).to have_content("Your email has been verified. Please log in.")
    expect(user.reload.email_verified?).to be(true)
  end

  it "does not verify the user email with an invalid token" do
    visit verify_email_path("invalid-token")

    expect(current_path).to eq(login_path)
    expect(page).to have_content("Verification link is invalid or has expired.")
    expect(user.reload.email_verified?).to be(false)
  end
end