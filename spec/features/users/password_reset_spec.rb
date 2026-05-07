require "rails_helper"
require "securerandom"

RSpec.describe "Password reset", type: :feature do
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

  it "shows a forgot password link on the login page" do
    visit login_path

    expect(page).to have_link("Forgot password?", href: new_password_reset_path)
  end

  it "sends password reset instructions for an existing user" do
    visit new_password_reset_path

    fill_in "Email", with: user.email

    perform_enqueued_jobs do
      click_button "Send Reset Instructions"
    end

    expect(current_path).to eq(login_path)
    expect(page).to have_content("If that email exists, password reset instructions have been sent.")
    expect(ActionMailer::Base.deliveries.count).to eq(1)

    email = ActionMailer::Base.deliveries.last

    expect(email.to).to eq([user.email])
    expect(email.subject).to eq("Reset your BodiMetrix password")
  end

  it "does not reveal whether an email exists" do
    visit new_password_reset_path

    fill_in "Email", with: "missing-#{SecureRandom.hex(4)}@example.com"
    click_button "Send Reset Instructions"

    expect(current_path).to eq(login_path)
    expect(page).to have_content("If that email exists, password reset instructions have been sent.")
    expect(ActionMailer::Base.deliveries.count).to eq(0)
  end

  it "resets the password with a valid token" do
    token = user.password_reset_token

    visit edit_password_reset_path(token)

    fill_in "New Password", with: "newsecure123"
    fill_in "Confirm New Password", with: "newsecure123"
    click_button "Reset Password"

    expect(current_path).to eq(login_path)
    expect(page).to have_content("Your password has been reset. Please log in.")

    visit login_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "newsecure123"
    click_button "Log In"

    expect(page).to have_content("Logged in successfully.")
    expect(current_path).to eq(profile_path(profile))
  end

  it "does not reset the password with an invalid token" do
    visit edit_password_reset_path("invalid-token")

    expect(current_path).to eq(new_password_reset_path)
    expect(page).to have_content("Password reset link is invalid or has expired.")
  end

  it "shows errors when the new password is invalid" do
    token = user.password_reset_token

    visit edit_password_reset_path(token)

    fill_in "New Password", with: "short"
    fill_in "Confirm New Password", with: "short"
    click_button "Reset Password"

    expect(page).to have_content("Password is too short")
  end
end