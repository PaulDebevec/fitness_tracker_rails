require "rails_helper"

RSpec.describe "Measurement photo upload", type: :feature do
    it "can create a new measurement with a body part photo" do
        profile = Profile.create!(display_name: "Paul", default_unit: "in")
        check_in = profile.check_ins.create!(checked_in_on: Date.current, notes: "Weekly update")
    
        visit new_profile_check_in_measurement_path(profile, check_in)
    
        select "Waist", from: "Body part"
        fill_in "Value", with: 34.5
        attach_file "Photo", Rails.root.join("spec/fixtures/files/upper_back.png")
    
        click_button "Create Measurement"
    
        measurement = Measurement.last
    
        expect(current_path).to eq(profile_check_in_measurement_path(profile, check_in, measurement))
        expect(page).to have_content("Measurement created successfully.")
        expect(measurement.body_part_photo).to be_attached
        expect(page).to have_css("img")
    end

    it "can update a measurement with a body part photo" do
        profile = Profile.create!(display_name: "Paul", default_unit: "in")
        check_in = profile.check_ins.create!(checked_in_on: Date.current, notes: "Weekly update")
        measurement = check_in.measurements.create!(body_part: "waist", value: 34.5)
      
        visit edit_profile_check_in_measurement_path(profile, check_in, measurement)
      
        attach_file "Photo", Rails.root.join("spec/fixtures/files/upper_back.png")
        click_button "Update Measurement"
      
        expect(current_path).to eq(profile_check_in_measurement_path(profile, check_in, measurement))
        expect(page).to have_content("Measurement updated successfully.")
        expect(measurement.reload.body_part_photo).to be_attached
        expect(page).to have_css("img")
    end
end