require "rails_helper"

RSpec.describe Profile, type: :model do
    subject(:profile) {described_class.new(display_name: "Paul", unit_system: "imperial")}
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
    
    # describe "#abbreviated_unit_system" do
    #     it "returns the default unit abbreviation" do
    #       profile = described_class.new(display_name: "Paul", unit_system: "imperial")
      
    #       expect(profile.abbreviated_unit_system).to eq("imperial")
    #     end
    # end
end