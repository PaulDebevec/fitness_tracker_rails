require "rails_helper"

RSpec.describe "Profile authorization", type: :feature do
  before(:each) do
    @public_owner = User.create!(
      email: "public_owner@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @public_prof = Profile.create!(
      user: @public_owner,
      display_name: "PublicOwn",
      unit_system: "imperial",
      public_profile: true
    )

    @private_owner = User.create!(
      email: "private_owner@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @private_profile = Profile.create!(
      user: @private_owner,
      display_name: "PrivateOwn",
      unit_system: "imperial",
      public_profile: false
    )

    @viewer = User.create!(
      email: "viewer@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @viewer_profile = Profile.create!(
      user: @viewer,
      display_name: "Viewer",
      unit_system: "imperial",
      public_profile: true
    )

    @admin = User.create!(
      email: "admin@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "admin"
    )

    @admin_profile = Profile.create!(
      user: @admin,
      display_name: "Admin",
      unit_system: "imperial",
      public_profile: true
    )
  end

  it "allows a guest to view a public profile" do
    visit profile_path(@public_prof)

    expect(page).to have_content("PublicOwn")
    expect(page).to have_link("View Progress Report")
  end

  it "prevents a guest from viewing a private profile" do
    visit profile_path(@private_profile)

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("You are not authorized to view that profile.")
  end

  it "allows a logged-in user to view another user's public profile" do
    log_in_with(email: "viewer@example.com")

    visit profile_path(@public_prof)

    expect(page).to have_content("PublicOwn")
    expect(page).to have_link("View Progress Report")
  end

  it "prevents a logged-in user from viewing another user's private profile" do
    log_in_with(email: "viewer@example.com")

    visit profile_path(@private_profile)

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("You are not authorized to view that profile.")
  end

  it "allows the owner to view their own private profile" do
    log_in_with(email: "private_owner@example.com")

    visit profile_path(@private_profile)

    expect(page).to have_content("PrivateOwn")
  end

  it "allows an admin to view another user's private profile" do
    log_in_with(email: "admin@example.com")

    visit profile_path(@private_profile)

    expect(page).to have_content("PrivateOwn")
  end

  it "shows owner-only management actions only to the owner" do
    log_in_with(email: "private_owner@example.com")

    visit profile_path(@private_profile)

    expect(page).to have_link("New Check-in")
  end

  it "does not show owner-only management actions to another logged-in user" do
    log_in_with(email: "viewer@example.com")

    visit profile_path(@public_prof)

    expect(page).not_to have_link("New Check-in")
    expect(page).to have_link("View Progress Report")
  end

  it "does not show owner-only management actions to a guest viewing a public profile" do
    visit profile_path(@public_prof)

    expect(page).not_to have_link("New Check-in")
    expect(page).to have_link("View Progress Report")
  end
end