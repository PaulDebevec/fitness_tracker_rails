require "rails_helper"

RSpec.describe "User signup", type: :feature do
  it "creates a user and associated profile" do
    visit signup_path

    fill_in "Email", with: "paul@example.com"
    fill_in "Password", with: "supersecure123"
    fill_in "Confirm Password", with: "supersecure123"
    fill_in "Display Name", with: "Paul"
    select "Imperial", from: "Unit System"

    click_button "Create Account"

    user = User.find_by(email: "paul@example.com")

    expect(user).to be_present
    expect(user.profile).to be_present
    expect(user.profile.display_name).to eq("Paul")
    expect(user.profile.unit_system).to eq("imperial")
    expect(page).to have_current_path(profile_path(user.profile))
    expect(page).to have_content("Account created successfully.")
  end
end