require "rails_helper"

RSpec.describe "Profile", type: :feature do
  before(:each) do
    @public_owner = User.create!(
      email: "public_owner@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @public_profile = Profile.create!(
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

  def log_in_as(email)
    visit login_path
    fill_in "Email", with: email
    fill_in "Password", with: "supersecure123"
    click_button "Log In"
  end

  describe "profile index" do
    it "shows public profiles to guests" do
      visit profiles_path

      expect(page).to have_content("PublicOwn")
      expect(page).to have_content("Viewer")
      expect(page).to have_content("Admin")
      expect(page).not_to have_content("PrivateOwn")
    end

    it "shows public profiles and the user's own private profile to a logged-in user" do
      log_in_with(email: "private_owner@example.com")

      visit profiles_path

      expect(page).to have_content("PrivateOwn")
      expect(page).to have_content("PublicOwn")
      expect(page).to have_content("Viewer")
    end

    it "shows all profiles to an admin" do
      log_in_with(email: "admin@example.com")

      visit profiles_path

      expect(page).to have_content("PrivateOwn")
      expect(page).to have_content("PublicOwn")
      expect(page).to have_content("Viewer")
      expect(page).to have_content("Admin")
    end
  end

  describe "profile show" do
    it "allows guests to view public profiles" do
      visit profile_path(@public_profile)

      expect(page).to have_content("PublicOwn")
      expect(page).to have_link("View Progress Report")
    end

    it "does not allow guests to view private profiles" do
      visit profile_path(@private_profile)

      expect(current_path).to eq(root_path)
      expect(page).to have_content("You are not authorized to view that profile.")
    end

    it "allows the owner to view their private profile" do
      log_in_with(email: "private_owner@example.com")

      visit profile_path(@private_profile)

      expect(page).to have_content("PrivateOwn")
    end

    it "allows an admin to view private profiles" do
      log_in_with(email: "admin@example.com")

      visit profile_path(@private_profile)

      expect(page).to have_content("PrivateOwn")
    end
  end

  describe "profile management controls" do
    it "shows new check-in controls to the owner" do
      log_in_with(email: "public_owner@example.com")

      visit profile_path(@public_profile)

      expect(page).to have_link("New Check-in")
    end

    it "does not show owner controls to guests viewing a public profile" do
      visit profile_path(@public_profile)

      expect(page).not_to have_link("New Check-in")
      expect(page).to have_link("View Progress Report")
    end

    it "does not show owner controls to another logged-in user viewing a public profile" do
      log_in_with(email: "viewer@example.com")

      visit profile_path(@public_profile)

      expect(page).not_to have_link("New Check-in")
      expect(page).to have_link("View Progress Report")
    end
  end

  describe "missing profiles" do
    it "shows a not found message for a missing profile" do
      missing_id = Profile.maximum(:id).to_i + 1

      visit profile_path(missing_id)

      expect(page).to have_content("Profile not found")
    end

    it "redirects from edit page for a missing profile" do
      log_in_with(email: "admin@example.com")

      visit "/profiles/999999/edit"

      expect(page).to have_content("Profile not found")
    end
  end

  describe "check-in cards on profile show" do
    before(:each) do
      @check_in = @public_profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Weekly progress update"
      )
    end

    it "shows read-only check-in cards to guests with a login prompt" do
      visit profile_path(@public_profile)

      expect(page).to have_content(@check_in.formatted_date)
      expect(page).to have_content("Weekly progress update")
      expect(page).to have_link("Log in to view details")
      expect(page).not_to have_content("Tap to view details")
    end

    it "links check-in cards to check-in show pages for logged-in users" do
      log_in_with(email: "viewer@example.com")

      visit profile_path(@public_profile)

      expect(page).to have_content(@check_in.formatted_date)
      expect(page).to have_content("Details")

      click_link "Details"

      expect(current_path).to eq(profile_check_in_path(@public_profile, @check_in))
      expect(page).to have_content("Weekly progress update")
    end
  end
end