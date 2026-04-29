require "rails_helper"
require "securerandom"

RSpec.describe "User destroy", type: :feature do
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

    before do
        profile
        log_in_with(email: user.email)
    end

    describe "deleting an account" do
        it "deletes the account (user and associated profile) when delete confirmation is typed case-insensitively" do
            visit edit_settings_path
            
            fill_in "Type DELETE to confirm", with: "delete"
            click_button "Delete Account"
            
            expect(current_path).to eq(root_path)
            expect(page).to have_content("Account deleted successfully.")
            expect(User.exists?(user.id)).to be(false)
        end

        it "does not delete the account without typing delete confirmation" do
            visit edit_settings_path
            
            click_button "Delete Account"
            
            expect(page).to have_content("Please type DELETE to confirm account deletion.")
            expect(User.exists?(user.id)).to be(true)
        end

        it "does not delete the account when something other than 'delete' is typed into confirmation" do
            visit edit_settings_path
            
            fill_in "Type DELETE to confirm", with: "NOTdelete"
            click_button "Delete Account"

            expect(page).to have_content("Please type DELETE to confirm account deletion.")
            expect(User.exists?(user.id)).to be(true)
        end
    end
end