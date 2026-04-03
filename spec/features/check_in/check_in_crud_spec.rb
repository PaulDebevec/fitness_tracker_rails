require 'rails_helper'

RSpec.describe "Check In", type: :feature do
    it "can create a new check-in" do
        profile = Profile.create!(display_name: "Paul", default_unit: "in")
    
        visit new_profile_check_in_path(profile)
    
        fill_in "Checked in on", with: Date.current
        fill_in "Notes", with: "Felt strong this week"
        click_button "Create Check-in"
    
        expect(page).to have_content("Check-in created successfully.")
        expect(page).to have_content(Date.current.to_s)
        expect(page).to have_content("Felt strong this week")
    end
end