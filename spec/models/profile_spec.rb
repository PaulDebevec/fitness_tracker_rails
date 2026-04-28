require "rails_helper"

RSpec.describe Profile, type: :model do
    let(:user) do 
        User.create!(email: "paul@example.com", password: "supersecure123", password_confirmation: "supersecure123", role: "user")
    end

    subject(:profile) {described_class.new(display_name: "Paul", unit_system: "imperial", user: user)}
    describe "relationships" do
        it { should belong_to(:user) }
    end

    describe "profile must be valid" do
        it "has valid attributes" do
            expect(profile).to be_valid
        end

        it "is invalid without a display_name" do
            profile.display_name = nil
            expect(profile).not_to be_valid
        end

        it "has a default unit" do
            profile.unit_system = nil
            expect(profile).not_to be_valid
        end

        it "is invalid with an unsupported unit_system" do
            profile.unit_system = "lbs"
            expect(profile).not_to be_valid
        end
    end

    describe "#has_any_check_in_photos?" do
        it "returns false when the profile has no check-ins" do
          expect(profile.has_any_check_in_photos?).to be(false)
        end
      
        it "returns false when check-ins exist but none have photos" do
          profile.check_ins.create!(
            checked_in_on: Date.current,
            notes: "No photos"
          )
      
          expect(profile.has_any_check_in_photos?).to be(false)
        end
      
        it "returns true when at least one check-in has a photo" do
          check_in = profile.check_ins.create!(
            checked_in_on: Date.current,
            notes: "With photo"
          )
      
          check_in.front_photo.attach(test_image_upload("front_photo.png"))
      
          expect(profile.has_any_check_in_photos?).to be(true)
        end
      end
end