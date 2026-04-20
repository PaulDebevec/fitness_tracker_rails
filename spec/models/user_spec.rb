require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject(:user) do
      described_class.new(
        email: "paul@example.com",
        password: "supersecure123",
        password_confirmation: "supersecure123",
        role: "user"
      )
    end

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    it "is valid with a valid email, password, and role" do
      user = described_class.new(
        email: "paul@example.com",
        password: "supersecure123",
        password_confirmation: "supersecure123",
        role: "user"
      )

      expect(user).to be_valid
    end

    it "normalizes email before validation" do
      user = described_class.create!(
        email: "  PAUL@EXAMPLE.COM ",
        password: "supersecure123",
        password_confirmation: "supersecure123",
        role: "user"
      )

      expect(user.email).to eq("paul@example.com")
    end

    it "requires a sufficiently long password" do
      user = described_class.new(
        email: "paul@example.com",
        password: "short",
        password_confirmation: "short",
        role: "user"
      )

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 12 characters)")
    end

    it "defaults role to user" do
      user = described_class.create!(
        email: "paul@example.com",
        password: "supersecure123",
        password_confirmation: "supersecure123"
      )

      expect(user.role).to eq("user")
    end
  end

  describe "#authenticate" do
    it "authenticates with the correct password" do
      user = described_class.create!(
        email: "paul@example.com",
        password: "supersecure123",
        password_confirmation: "supersecure123",
        role: "user"
      )

      expect(user.authenticate("supersecure123")).to eq(user)
      expect(user.authenticate("wrongpassword")).to be(false)
    end
  end
end