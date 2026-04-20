require "rails_helper"

RSpec.describe "CheckIn photo upload", type: :feature do
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

    it "can create a new check-in with progress photos" do
        visit new_profile_check_in_path(@profile)
    
        fill_in "Check-in Date", with: Date.current
        fill_in "Notes", with: "Photo upload test"
    
        attach_file "check_in_front_photo", Rails.root.join("spec/fixtures/files/front_photo.png")
        attach_file "check_in_back_photo", Rails.root.join("spec/fixtures/files/back_photo.png")
        attach_file "check_in_side_photo", Rails.root.join("spec/fixtures/files/side_photo.png")
    
        click_button "Create Check-in"
    
        check_in = CheckIn.last
    
        expect(current_path).to eq(profile_check_in_path(@profile, check_in))
        expect(page).to have_content("Check-in created successfully.")
        expect(check_in.front_photo).to be_attached
        expect(check_in.back_photo).to be_attached
        expect(check_in.side_photo).to be_attached
        expect(page).to have_css("img")
    end

    it "can update a check-in with progress photos" do
        check_in = @profile.check_ins.create!(checked_in_on: Date.current, notes: "Original")
    
        visit edit_profile_check_in_path(@profile, check_in)
    
        attach_file "check_in_front_photo", Rails.root.join("spec/fixtures/files/front_photo.png")
        attach_file "check_in_back_photo", Rails.root.join("spec/fixtures/files/back_photo.png")
        attach_file "check_in_side_photo", Rails.root.join("spec/fixtures/files/side_photo.png")
    
        click_button "Update Check-in"
    
        expect(current_path).to eq(profile_check_in_path(@profile, check_in))
        expect(page).to have_content("Check-in updated successfully.")
        expect(check_in.reload.front_photo).to be_attached
        expect(check_in.reload.back_photo).to be_attached
    end
end