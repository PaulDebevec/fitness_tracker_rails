require "rails_helper"
require "securerandom"

RSpec.describe User, type: :model do
  let(:email) { "paul-#{SecureRandom.hex(4)}@example.com" }

  subject(:user) do
    described_class.new(
      email: email,
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )
  end

  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    it "is valid with a valid email, password, and role" do
      expect(user).to be_valid
    end

    it "normalizes email before validation" do
      user = described_class.create!(
        email: "  PAUL_1@EXAMPLE.COM ",
        password: "supersecure123",
        password_confirmation: "supersecure123",
        role: "user"
      )

      expect(user.email).to eq("paul_1@example.com")
    end

    it "requires a sufficiently long password" do
      user.password = "short"
      user.password_confirmation = "short"

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 10 characters)")
    end

    it "defaults role to user" do
      user = described_class.create!(
        email: "default-#{SecureRandom.hex(4)}@example.com",
        password: "supersecure123",
        password_confirmation: "supersecure123"
      )

      expect(user.role).to eq("user")
    end
  end

  describe "associations" do
    it { should have_one(:profile).dependent(:destroy) }
  end

  describe "#authenticate" do
    let!(:user) do
      described_class.create!(
        email: email,
        password: "supersecure123",
        password_confirmation: "supersecure123",
        role: "user"
      )
    end

    it "authenticates with the correct password" do
      expect(user.authenticate("supersecure123")).to eq(user)
      expect(user.authenticate("wrongpassword")).to be(false)
    end
  end

  describe "email verification" do
    it "returns false when the user has not verified their email" do
      expect(user.email_verified?).to be(false)
    end
  
    it "returns true when the user has verified their email" do
      user.email_verified_at = Time.current
  
      expect(user.email_verified?).to be(true)
    end
  
    it "marks the user email as verified" do
      user.save!
  
      user.mark_email_as_verified!
  
      expect(user.email_verified?).to be(true)
    end
  
    it "generates an email verification token" do
      user.save!
  
      expect(user.email_verification_token).to be_present
    end
  
    it "generates a password reset token" do
      user.save!
  
      expect(user.password_reset_token).to be_present
    end
  end
end