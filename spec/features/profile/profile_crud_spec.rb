require 'rails_helper'

RSpec.describe "Profile", type: :feature do
    describe "CRUD Functionality" do
        it "can create new profiles" do
            visit "/profiles/new"
            expect(current_path).to eq("/profiles/new")

            fill_in "Display name", with: "John-Patrick"
            select "Inches", from: "Default unit"

            click_button "Create Profile"

            profile_id = Profile.last.id
            expect(current_path).to eq("/profiles/#{profile_id}")
            # expect(page).to have_content("Profile created successfully")
            expect(page).to have_content("John-Patrick")
        end

        it "can read a single profile/profile show" do
            Profile.create!(display_name: "Pauly Do Little", default_unit: "in")
            visit "/profiles/#{Profile.last.id}"
            expect(page).to have_content("Pauly Do Little")
            expect(page).to have_content("No check-in history yet.")
        end

        it "can read multiple profiles/profile index" do
            Profile.create!(display_name: "Pauly Do Lottle", default_unit: "in")
            Profile.create!(display_name: "Hope Johnstein", default_unit: "in")
            Profile.create!(display_name: "John Hopenstein", default_unit: "in")
            Profile.create!(display_name: "Harry Buttler", default_unit: "in")

            visit "/profiles"
            expect(page).to have_content("Pauly Do Lottle")
            expect(page).to have_content("Hope Johnstein")
            expect(page).to have_content("John Hopenstein")
            expect(page).to have_content("Harry Buttler")
        end

        it "can update a profile" do
            profile_1 = Profile.create!(display_name: "Pauly Do Lottle", default_unit: "in")

            visit "profiles/#{profile_1.id}"
            expect(current_path).to eq("/profiles/#{profile_1.id}")
            expect(page).to have_content("Pauly Do Lottle")

            click_link "Edit Profile"
            expect(current_path).to eq("/profiles/#{profile_1.id}/edit")
            fill_in "Display name", with: "Pauly Pocket"
            click_button "Update Profile"

            expect(current_path).to eq("/profiles/#{profile_1.id}")
            expect(page).to have_content("Pauly Pocket")
        end

        it "can destroy a profile" do
            profile_1 = Profile.create!(display_name: "Pauly Do Lottle", default_unit: "in")
            profile_2 = Profile.create!(display_name: "Harry Buttler", default_unit: "in")

            expect(Profile.all.count).to eq(2)
            visit "profiles" 
            expect(page).to have_content("Pauly Do Lottle")
            expect(page).to have_content("Harry Buttler")

            visit "profiles/#{profile_1.id}" 
            click_button "Delete Profile"
            expect(Profile.all.count).to eq(1)
            expect(page).to have_content("Harry Buttler")
            expect(page).not_to have_content("Pauly Do Lottle")
        end
    end

    describe "Profile CRUD sad paths/edge cases" do
        it "new profile with no display_name" do
            visit "/profiles/new"
            expect(current_path).to eq("/profiles/new")

            fill_in "Display name", with: ""
            select "Inches", from: "Default unit"

            click_button "Create Profile"
            expect(page).to have_content("Display name can't be blank")
            expect(page).to have_content("Display name is too short (minimum is 2 characters)")
        end

        it "visit show page of non-existant profile" do
            missing_id = Profile.maximum(:id).to_i + 1
            visit "/profiles/#{missing_id}"
            expect(page).to have_content("Profile not found")
        end

        it "new profile with display_name too short" do
            visit "/profiles/new"
          
            fill_in "Display name", with: "J"
            select "Inches", from: "Default unit"
            click_button "Create Profile"
          
            expect(page).to have_content("Display name is too short")
        end

        it "new profile with display_name too long" do
            visit "/profiles/new"
          
            fill_in "Display name", with: "J" * 51
            select "Inches", from: "Default unit"
            click_button "Create Profile"
          
            expect(page).to have_content("Display name is too long")
        end

        it "cannot update a profile with invalid data" do
            profile = Profile.create!(display_name: "John", default_unit: "in")
          
            visit edit_profile_path(profile)
          
            fill_in "Display name", with: ""
            select "Inches", from: "Default unit"
            click_button "Update Profile"
          
            expect(page).to have_content("Display name can't be blank")
            expect(profile.reload.display_name).to eq("John")
        end

        it "visit edit page of non-existent profile" do
            visit "/profiles/999999/edit"
          
            expect(current_path).to eq("/profiles")
            expect(page).to have_content("Profile not found.")
        end

        it "shows an empty state when there are no profiles" do
            Profile.destroy_all
          
            visit "/profiles"
          
            expect(page).to have_content("No profiles yet.")
        end

        it "shows no check-ins message on profile show page" do
            profile = Profile.create!(display_name: "John", default_unit: "in")
          
            visit profile_path(profile)
          
            expect(page).to have_content("No check-in history yet.")
        end
    end

    describe "profile functionality" do
        it "links a profile's check-ins to their show pages" do
            profile = Profile.create!(display_name: "John-Patrick", default_unit: "in")
            check_in = profile.check_ins.create!(
              checked_in_on: Date.current,
              notes: "Weekly progress update"
            )
          
            visit profile_path(profile)
          
            expect(page).to have_link(check_in.formatted_date)
          
            click_link check_in.formatted_date
          
            expect(current_path).to eq(profile_check_in_path(profile, check_in))
            expect(page).to have_content(check_in.formatted_date)
            expect(page).to have_content("Weekly progress update")
          end
    end
end
