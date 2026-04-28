require "rails_helper"

RSpec.describe CheckIn, type: :model do
  describe "validations" do
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

      @check_in = @profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Weekly update"
      )
    end

    it { should validate_presence_of(:checked_in_on) }
    it { should belong_to(:profile) }

    it "is valid with valid attributes" do
      expect(@check_in).to be_valid
    end

    it "is invalid without a profile" do
      @check_in.profile = nil
      expect(@check_in).not_to be_valid
    end

    it "is invalid without a checked_in_on date" do
      @check_in.checked_in_on = nil
      expect(@check_in).not_to be_valid
      expect(@check_in.errors[:checked_in_on]).to include("can't be blank")
    end

    it "is invalid with a future checked_in_on date" do
      @check_in.checked_in_on = Date.current + 1.day
      expect(@check_in).not_to be_valid
      expect(@check_in.errors[:checked_in_on]).to include("can't be in the future")
    end

    it "is valid with today's date" do
      @check_in.checked_in_on = Date.current
      expect(@check_in).to be_valid
    end

    it "is valid with a past date" do
      @check_in.checked_in_on = Date.yesterday
      expect(@check_in).to be_valid
    end
    
  it "does not allow duplicate check-in dates for the same profile" do
      duplicate = @profile.check_ins.create(
        checked_in_on: @check_in.checked_in_on,
        notes: "Weekly update"
      )
    
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:checked_in_on]).to include("has already been taken")
    end
  end
  
  describe "scopes" do
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

      @newer_check_in = @profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Newer"
      )

      @older_check_in = @profile.check_ins.create!(
        checked_in_on: Date.current - 7.days,
        notes: "Older"
      )
    end

    it "orders check-ins chronologically" do  
      expect(@profile.check_ins.chronological).to eq([@older_check_in, @newer_check_in])
    end
  
    it "orders check-ins in reverse chronological order" do
      expect(@profile.check_ins.reverse_chronological).to eq([@newer_check_in, @older_check_in])
    end

    it "allows the same check-in date for different profiles" do
      user_2 = User.create!(
        email: "other_profile@example.com",
        password: "supersecure123",
        password_confirmation: "supersecure123",
        role: "user"
      )
    
      profile_2 = Profile.create!(
        user: user_2,
        display_name: "other profile",
        unit_system: "imperial"
      )

      check_in_duplicate_date = profile_2.check_ins.create!(
        checked_in_on: @newer_check_in.checked_in_on,
        notes: "Check-in"
      )

      expect(check_in_duplicate_date).to be_valid
    end
  end

  describe "#has_photos?" do
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

    it "returns false when no photos are attached" do
      check_in = @profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "No photos"
      )
  
      expect(check_in.has_photos?).to be(false)
    end
  
    it "returns true when a front photo is attached" do
      check_in = @profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "With photo"
      )

      check_in.front_photo.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/front_photo.png")),
        filename: "front_photo.png",
        content_type: "image/png"
      )
  
      expect(check_in.has_photos?).to be(true)
    end
  
    it "returns true when a back photo is attached" do
      check_in = @profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "With photo"
      )
  
      check_in.back_photo.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/back_photo.png")),
        filename: "back_photo.png",
        content_type: "image/png"
      )
  
      expect(check_in.has_photos?).to be(true)
    end
  
    it "returns true when a side photo is attached" do
      check_in = @profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "With photo"
      )
  
      check_in.side_photo.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/side_photo.png")),
        filename: "side_photo.png",
        content_type: "image/png"
      )
  
      expect(check_in.has_photos?).to be(true)
    end
  end
end