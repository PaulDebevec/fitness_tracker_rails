require "rails_helper"

RSpec.describe "CheckIn", type: :feature do
    describe "CRUD Functionality" do
        let!(:profile) { Profile.create!(display_name: "Paul", default_unit: "in") }

        it "can create a new check-in" do
            visit new_profile_check_in_path(profile)

            fill_in "Checked in on", with: Date.current
            fill_in "Notes", with: "Felt strong this week"
            click_button "Create Check-in"

            check_in = CheckIn.last
            expect(current_path).to eq(profile_check_in_path(profile, check_in))
            expect(page).to have_content("Check-in created successfully.")
            expect(page).to have_content(check_in.formatted_date)
            expect(page).to have_content("Felt strong this week")
        end

        it "can read a single check-in" do
            check_in = profile.check_ins.create!(
            checked_in_on: Date.current,
            notes: "Good workout"
            )

            visit profile_check_in_path(profile, check_in)

            expect(page).to have_content(check_in.formatted_date)
            expect(page).to have_content("Good workout")
        end

        it "can read multiple check-ins" do
            check_in_1 = profile.check_ins.create!(
                checked_in_on: Date.current,
                notes: "First note"
            )

            check_in_2 = profile.check_ins.create!(
                checked_in_on: Date.yesterday,
                notes: "Second note"
            )

            visit profile_check_ins_path(profile)

            expect(page).to have_content(check_in_1.checked_in_on.to_s)
            expect(page).to have_content(check_in_2.checked_in_on.to_s)
            expect(page).to have_content("First note")
            expect(page).to have_content("Second note")
        end

        it "can update a check-in" do
            check_in = profile.check_ins.create!(
            checked_in_on: Date.current,
            notes: "Old note"
            )

            visit edit_profile_check_in_path(profile, check_in)

            fill_in "Notes", with: "Updated note"
            click_button "Update Check-in"

            expect(current_path).to eq(profile_check_in_path(profile, check_in))
            expect(page).to have_content("Check-in updated successfully.")
            expect(page).to have_content("Updated note")
            expect(check_in.reload.notes).to eq("Updated note")
        end

        it "can destroy a check-in" do
            check_in = profile.check_ins.create!(
            checked_in_on: Date.current,
            notes: "Delete me"
            )

            visit profile_check_in_path(profile, check_in)

            click_button "Delete Check-in"

            expect(current_path).to eq(profile_check_ins_path(profile))
            expect(page).to have_content("Check-in deleted successfully.")
            expect(CheckIn.exists?(check_in.id)).to be(false)
        end
    end

    describe "sad paths / edge cases" do
        let!(:profile) { Profile.create!(display_name: "Paul", default_unit: "in") }

        it "cannot create a check-in without a date" do
            visit new_profile_check_in_path(profile)

            fill_in "Notes", with: "Missing date"
            click_button "Create Check-in"

            expect(page).to have_content("Checked in on can't be blank")
        end

        it "cannot create a check-in with a future date" do
            visit new_profile_check_in_path(profile)

            fill_in "Checked in on", with: Date.current + 1.day
            fill_in "Notes", with: "Future entry"
            click_button "Create Check-in"

            expect(page).to have_content("Checked in on can't be in the future")
        end

        it "cannot update a check-in with invalid data" do
            check_in = profile.check_ins.create!(
                checked_in_on: Date.current,
                notes: "Original note"
            )

            visit edit_profile_check_in_path(profile, check_in)

            fill_in "Checked in on", with: ""
            click_button "Update Check-in"

            expect(page).to have_content("Checked in on can't be blank")
            expect(check_in.reload.checked_in_on).to eq(Date.current)
        end

        it "shows an empty state when a profile has no check-ins" do
            visit profile_check_ins_path(profile)

            expect(page).to have_content("No check-ins yet.")
            end

            it "redirects when visiting the show page of a non-existent check-in" do
            visit "/profiles/#{profile.id}/check_ins/999999"

            expect(current_path).to eq(profile_check_ins_path(profile))
            expect(page).to have_content("Check-in not found.")
        end

        it "redirects when visiting the edit page of a non-existent check-in" do
            visit "/profiles/#{profile.id}/check_ins/999999/edit"

            expect(current_path).to eq(profile_check_ins_path(profile))
            expect(page).to have_content("Check-in not found.")
        end
    end
end