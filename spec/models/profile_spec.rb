require "rails_helper"

RSpec.describe Profile, type: :model do
    subject(:profile) {described_class.new(display_name: "Paul", default_unit: "in")}
    describe "profile must be valid" do
        it "has valid attributes" do
            expect(profile).to be_valid
        end

        it "is invalid without a display_name" do
            profile.display_name = nil
            expect(profile).not_to be_valid
        end

        it "has a default unit" do
            profile.default_unit = nil
            expect(profile).not_to be_valid
        end

        it "is invalid with an unsupported default_unit" do
            profile.default_unit = "lbs"
            expect(profile).not_to be_valid
        end
    end
    
    describe "#abbreviated_default_unit" do
        it "returns the default unit abbreviation" do
          profile = described_class.new(display_name: "Paul", default_unit: "in")
      
          expect(profile.abbreviated_default_unit).to eq("in")
        end
    end
end