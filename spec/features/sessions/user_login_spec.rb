require "rails_helper"

RSpec.describe "User login", type: :feature do
  before(:each) do
    @user = User.create!(
      email: "paul@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @profile = Profile.create!(
      user: @user,
      display_name: "Paul",
      unit_system: "imperial"
    )
  end

  it "logs in with valid credentials" do
    visit login_path

    fill_in "Email", with: "paul@example.com"
    fill_in "Password", with: "supersecure123"
    click_button "Log In"

    expect(page).to have_current_path(profile_path(@profile))
    expect(page).to have_content("Logged in successfully.")
  end

  it "does not log in with invalid credentials" do
    visit login_path

    fill_in "Email", with: "paul@example.com"
    fill_in "Password", with: "wrongpassword"
    click_button "Log In"

    expect(page).to have_content("Invalid email or password.")
  end
end