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
end