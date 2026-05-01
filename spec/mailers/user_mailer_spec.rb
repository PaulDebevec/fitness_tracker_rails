require "rails_helper"
require "securerandom"

RSpec.describe UserMailer, type: :mailer do
  let(:user) do
    User.create!(
      email: "paul-#{SecureRandom.hex(4)}@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )
  end

  describe "email_verification" do
    let(:mail) { described_class.with(user: user).email_verification }

    it "renders the headers" do
      expect(mail.subject).to eq("Verify your BodiMetrix email")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["no-reply@bodimetrix.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Verify your email")
      expect(mail.body.encoded).to include("Welcome to BodiMetrix")
    end
  end

  describe "password_reset" do
    let(:mail) { described_class.with(user: user).password_reset }

    it "renders the headers" do
      expect(mail.subject).to eq("Reset your BodiMetrix password")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["no-reply@bodimetrix.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Reset your password")
      expect(mail.body.encoded).to include("If you did not request this")
    end
  end
end