require "rails_helper"

RSpec.describe "Measurement", type: :feature do
  describe "CRUD Functionality" do
    let!(:profile) { Profile.create!(display_name: "Paul", default_unit: "in") }
    let!(:check_in) { profile.check_ins.create!(checked_in_on: Date.current, notes: "Weekly update") }

    it "can read multiple measurements" do
      measurement_1 = check_in.measurements.create!(body_part: "waist", value: 34.5)
      measurement_2 = check_in.measurements.create!(body_part: "chest", value: 42.0)

      visit profile_check_in_measurements_path(profile, check_in)

      expect(page).to have_content("Measurements for #{check_in.formatted_date}")
      expect(page).to have_content(measurement_1.body_part.humanize)
      expect(page).to have_content(measurement_1.value)
      expect(page).to have_content(measurement_2.body_part.humanize)
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

      measurement = Measurement.last

      expect(current_path).to eq(profile_check_in_measurement_path(profile, check_in, measurement))
      expect(page).to have_content("Measurement created successfully.")
      expect(page).to have_content("Waist")
      expect(page).to have_content("34.5")
    end
  end

  describe "sad paths / edge cases" do
    let!(:profile) { Profile.create!(display_name: "Paul", default_unit: "in") }
    let!(:check_in) { profile.check_ins.create!(checked_in_on: Date.current, notes: "Weekly update") }

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

    it "shows an empty state when a check-in has no measurements" do
      visit profile_check_in_measurements_path(profile, check_in)

      expect(page).to have_content("No measurements yet.")
    end
  end
end