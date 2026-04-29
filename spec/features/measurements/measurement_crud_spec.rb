require "rails_helper"
require "securerandom"

RSpec.describe "Measurement", type: :feature do
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

  let(:check_in) do
    profile.check_ins.create!(
      checked_in_on: Date.current,
      notes: "Weekly update"
    )
  end

  before do
    profile
    check_in
    log_in_with(email: user.email)
  end

  describe "CRUD Functionality" do
    it "can read multiple measurements" do
      measurement_1 = check_in.measurements.create!(body_part: "waist", value: 34.5)
      measurement_2 = check_in.measurements.create!(body_part: "chest", value: 42.0)

      visit profile_check_in_measurements_path(profile, check_in)

      expect(page).to have_content("Measurements for #{check_in.formatted_date}")
      expect(page).to have_content(measurement_1.formatted_body_part)
      expect(page).to have_content(measurement_1.value)
      expect(page).to have_content(measurement_2.formatted_body_part)
      expect(page).to have_content(measurement_2.value)
    end

    it "can visit the new measurement page" do
      visit new_profile_check_in_measurement_path(profile, check_in)

      expect(page).to have_content("New Measurement for #{check_in.formatted_date}")
      expect(page).to have_select("Body part", options: ["Select a body part"] + Measurement::BODY_PARTS.map(&:humanize))
      expect(page).to have_field("Value")
    end

    it "can create a new measurement" do
      visit new_profile_check_in_measurement_path(profile, check_in)

      select "Waist", from: "Body part"
      fill_in "Value", with: 34.5
      click_button "Create Measurement"

      expect(current_path).to eq(profile_check_in_path(profile, check_in))
      expect(page).to have_content("Measurement created successfully.")
      expect(page).to have_content("Waist")
      expect(page).to have_content("34.5")
    end

    it "can read a single measurement" do
      measurement = check_in.measurements.create!(body_part: "waist", value: 34.5)

      visit profile_check_in_measurement_path(profile, check_in, measurement)

      expect(page).to have_content("Measurement for #{check_in.formatted_date}")
      expect(page).to have_content("Waist")
      expect(page).to have_content("34.5")
    end

    it "can update a measurement" do
      measurement = check_in.measurements.create!(body_part: "waist", value: 34.5)

      visit edit_profile_check_in_measurement_path(profile, check_in, measurement)

      select "Chest", from: "Body part"
      fill_in "Value", with: 42.0
      click_button "Update Measurement"

      expect(current_path).to eq(profile_check_in_measurement_path(profile, check_in, measurement))
      expect(page).to have_content("Measurement updated successfully.")
      expect(page).to have_content("Chest")
      expect(page).to have_content("42.0")
      expect(measurement.reload.body_part).to eq("chest")
      expect(measurement.reload.value.to_f).to eq(42.0)
    end

    it "can destroy a measurement" do
      measurement = check_in.measurements.create!(body_part: "waist", value: 34.5)

      visit profile_check_in_measurement_path(profile, check_in, measurement)
      click_button "Delete Measurement"

      expect(current_path).to eq(profile_check_in_measurements_path(profile, check_in))
      expect(page).to have_content("Measurement deleted successfully.")
      expect(Measurement.exists?(measurement.id)).to be(false)
    end
  end

  describe "sad paths / edge cases" do
    it "cannot create a measurement without a body part" do
      visit new_profile_check_in_measurement_path(profile, check_in)

      fill_in "Value", with: 34.5
      click_button "Create Measurement"

      expect(page).to have_content("Body part can't be blank")
    end

    it "cannot create a measurement without a value" do
      visit new_profile_check_in_measurement_path(profile, check_in)

      select "Waist", from: "Body part"
      click_button "Create Measurement"

      expect(page).to have_content("Value can't be blank")
    end

    it "cannot update a measurement with invalid data" do
      measurement = check_in.measurements.create!(body_part: "waist", value: 34.5)

      visit edit_profile_check_in_measurement_path(profile, check_in, measurement)

      select "Waist", from: "Body part"
      fill_in "Value", with: ""
      click_button "Update Measurement"

      expect(page).to have_content("Value can't be blank")
      expect(measurement.reload.value.to_f).to eq(34.5)
    end

    it "shows an empty state when a check-in has no measurements" do
      visit profile_check_in_measurements_path(profile, check_in)

      expect(page).to have_content("No measurements yet.")
    end

    it "redirects when visiting the show page of a non-existent measurement" do
      visit "/profiles/#{profile.id}/check_ins/#{check_in.id}/measurements/999999"

      expect(current_path).to eq(profile_check_in_measurements_path(profile, check_in))
      expect(page).to have_content("Measurement not found.")
    end

    it "redirects when visiting the edit page of a non-existent measurement" do
      visit "/profiles/#{profile.id}/check_ins/#{check_in.id}/measurements/999999/edit"

      expect(current_path).to eq(profile_check_in_measurements_path(profile, check_in))
      expect(page).to have_content("Measurement not found.")
    end
  end
end