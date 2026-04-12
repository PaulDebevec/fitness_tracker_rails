require "rails_helper"

RSpec.describe CheckIn, type: :model do
  subject(:check_in) do
    described_class.new(
      profile: profile,
      checked_in_on: Date.current,
      notes: "Weekly update"
    )
  end

  let(:profile) { Profile.create!(display_name: "Paul", unit_system: "imperial") }

  describe "associations" do
    it { should belong_to(:profile) }
  end

  describe "validations" do
    it { should validate_presence_of(:checked_in_on) }

    it "is valid with valid attributes" do
      expect(check_in).to be_valid
    end

    it "is invalid without a profile" do
      check_in.profile = nil
      expect(check_in).not_to be_valid
    end

    it "is invalid without a checked_in_on date" do
      check_in.checked_in_on = nil
      expect(check_in).not_to be_valid
      expect(check_in.errors[:checked_in_on]).to include("can't be blank")
    end

    it "is invalid with a future checked_in_on date" do
      check_in.checked_in_on = Date.current + 1.day
      expect(check_in).not_to be_valid
      expect(check_in.errors[:checked_in_on]).to include("can't be in the future")
    end

    it "is valid with today's date" do
      check_in.checked_in_on = Date.current
      expect(check_in).to be_valid
    end

    it "is valid with a past date" do
      check_in.checked_in_on = Date.yesterday
      expect(check_in).to be_valid
    end
    
  it "does not allow duplicate check-in dates for the same profile" do
      described_class.create!(
        profile: profile,
        checked_in_on: Date.current,
        notes: "First"
      )
    
      duplicate = described_class.new(
        profile: profile,
        checked_in_on: Date.current,
        notes: "Second"
      )
    
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:checked_in_on]).to include("has already been taken")
    end
  end
  
  describe "scopes" do
    it "orders check-ins chronologically" do
      older_check_in = profile.check_ins.create!(
        checked_in_on: Date.current - 7.days,
        notes: "Older"
      )
  
      newer_check_in = profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Newer"
      )
  
      expect(profile.check_ins.chronological).to eq([older_check_in, newer_check_in])
    end
  
    it "orders check-ins in reverse chronological order" do
      older_check_in = profile.check_ins.create!(
        checked_in_on: Date.current - 7.days,
        notes: "Older"
      )
  
      newer_check_in = profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Newer"
      )
  
      expect(profile.check_ins.reverse_chronological).to eq([newer_check_in, older_check_in])
    end

    it "allows the same check-in date for different profiles" do
      other_profile = Profile.create!(display_name: "Jamie", unit_system: "imperial")
    
      described_class.create!(
        profile: profile,
        checked_in_on: Date.current,
        notes: "First"
      )
    
      check_in = described_class.new(
        profile: other_profile,
        checked_in_on: Date.current,
        notes: "Second"
      )
    
      expect(check_in).to be_valid
    end
  end
end