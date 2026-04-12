require "rails_helper"

RSpec.describe "CheckIn photo upload", type: :feature do
    it "can create a new check-in with progress photos" do
        profile = Profile.create!(display_name: "Paul", unit_system: "imperial") 
    
        visit new_profile_check_in_path(profile)
    
        fill_in "Check-in Date", with: Date.current
        fill_in "Notes", with: "Photo upload test"
    
        attach_file "check_in_upper_front_photo", Rails.root.join("spec/fixtures/files/upper_front.png")
        attach_file "check_in_upper_back_photo", Rails.root.join("spec/fixtures/files/upper_back.png")
    
        click_button "Create Check-in"
    
        check_in = CheckIn.last
    
        expect(current_path).to eq(profile_check_in_path(profile, check_in))
        expect(page).to have_content("Check-in created successfully.")
        expect(check_in.upper_front_photo).to be_attached
        expect(check_in.upper_back_photo).to be_attached
        expect(page).to have_css("img")
    end

    it "can update a check-in with progress photos" do
        profile = Profile.create!(display_name: "Paul", unit_system: "imperial")
        check_in = profile.check_ins.create!(checked_in_on: Date.current, notes: "Original")
      
        visit edit_profile_check_in_path(profile, check_in)
      
        attach_file "check_in_lower_front_photo", Rails.root.join("spec/fixtures/files/upper_front.png")
        attach_file "check_in_lower_back_photo", Rails.root.join("spec/fixtures/files/upper_back.png")
      
        click_button "Update Check-in"
      
        expect(current_path).to eq(profile_check_in_path(profile, check_in))
        expect(page).to have_content("Check-in updated successfully.")
        expect(check_in.reload.lower_front_photo).to be_attached
        expect(check_in.reload.lower_back_photo).to be_attached
      end
end