require "rails_helper"

RSpec.describe "Profile authorization", type: :feature do
  before(:each) do
    @user_one = User.create!(
      email: "one@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @profile_one = Profile.create!(
      user: @user_one,
      display_name: "User One",
      unit_system: "imperial"
    )

    @user_two = User.create!(
      email: "two@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @profile_two = Profile.create!(
      user: @user_two,
      display_name: "User Two",
      unit_system: "imperial"
    )
  end

  it "prevents a user from viewing another user's profile" do
    visit login_path
    fill_in "Email", with: "one@example.com"
    fill_in "Password", with: "supersecure123"
    click_button "Log In"

    visit profile_path(@profile_two)

    expect(page).to have_content("You are not authorized to access that page.")
  end

  it "redirects guests to login" do
    visit profile_path(@profile_one)
  
    expect(page).to have_current_path(login_path)
    expect(page).to have_content("You must be logged in to access that page.")
  end

  it "allows an admin to access another user's profile" do
    admin = User.create!(
      email: "admin@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "admin"
    )
  
    admin_profile = Profile.create!(
      user: admin,
      display_name: "Admin",
      unit_system: "imperial"
    )
  
    visit login_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Password", with: "supersecure123"
    click_button "Log In"
  
    visit profile_path(@profile_two)
  
    expect(page).to have_content("User Two")
  end
end