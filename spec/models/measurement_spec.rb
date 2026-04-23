require 'rails_helper'

RSpec.describe Measurement, type: :model do
  describe "associations" do
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
      @measurement = @check_in.measurements.create!(
        body_part: "waist",
        value: 34.5
      )
    end

    it { should belong_to(:check_in) }
  end

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
      @measurement = @check_in.measurements.create!(
        body_part: "waist",
        value: 34.5
      )
    end

    it "is valid with valid attributes" do
      expect(@measurement).to be_valid
    end

    it "is invalid without a check_in" do
      @measurement.check_in = nil

      expect(@measurement).not_to be_valid
      expect(@measurement.errors[:check_in]).to include("must exist")
    end

    it "is invalid without a body_part" do
      @measurement.body_part = nil

      expect(@measurement).not_to be_valid
      expect(@measurement.errors[:body_part]).to include("can't be blank")
    end

    it "is invalid with an unsupported body_part" do
      @measurement.body_part = "forearm"

      expect(@measurement).not_to be_valid
      expect(@measurement.errors[:body_part]).to include("is not included in the list")
    end

    it "is valid for each allowed body part" do
      Measurement::BODY_PARTS.each do |body_part|
        @measurement.body_part = body_part
        expect(@measurement).to be_valid
      end
    end

    it "is invalid without a value" do
      @measurement.value = nil

      expect(@measurement).not_to be_valid
      expect(@measurement.errors[:value]).to include("can't be blank")
    end

    it "is invalid with a value of 0" do
      @measurement.value = 0

      expect(@measurement).not_to be_valid
      expect(@measurement.errors[:value]).to include("must be greater than 0")
    end

    it "is invalid with a negative value" do
      @measurement.value = -2

      expect(@measurement).not_to be_valid
      expect(@measurement.errors[:value]).to include("must be greater than 0")
    end

    it "is valid with a positive decimal value" do
      @measurement.value = 15.75

      expect(@measurement).to be_valid
    end

    it "does not allow duplicate body parts for the same check_in" do
      duplicate = @check_in.measurements.create(
        body_part: "waist",
        value: 34.5
      )
    
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:body_part]).to include("has already been taken")
    end
    
    it "allows the same body part on different check_ins" do
      check_in_2 = @profile.check_ins.create!(
        checked_in_on: Date.current - 7.days,
        notes: "Weekly update"
      )
      measurement = check_in_2.measurements.create!(
        body_part: "waist",
        value: 34.5
      )

      expect(measurement).to be_valid
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

      @check_in = @profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Weekly update"
      )
      @waist_measurement = @check_in.measurements.create!(
        body_part: "waist",
        value: 34.5
      )
      @chest_measurement = @check_in.measurements.create!(
        body_part: "chest",
        value: 42.0
      )
    end
  
    it "filters measurements by body part" do
      expect(Measurement.for_body_part("waist")).to include(@waist_measurement)
      expect(Measurement.for_body_part("waist")).not_to include(@chest_measurement)
    end
  
    it "orders measurements by body part" do
      expect(@check_in.measurements.ordered_by_body_part).to eq([@chest_measurement, @waist_measurement])
    end
  end

  describe "#formatted_body_part" do
    it "returns a humanized body part name" do
      user = User.create!(
        email: "paul@example.com",
        password: "supersecure123",
        password_confirmation: "supersecure123",
        role: "user"
      )
    
      profile = Profile.create!(
        user: user,
        display_name: "Paul",
        unit_system: "imperial"
      )

      check_in = profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Weekly update"
      )
      measurement = check_in.measurements.create!(
        body_part: "bicep_left",
        value: 34.5
      )
  
      expect(measurement.formatted_body_part).to eq("Bicep left")
    end
  end
end
