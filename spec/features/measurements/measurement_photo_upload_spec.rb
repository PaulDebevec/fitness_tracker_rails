require "rails_helper"
require "securerandom"

RSpec.describe "Measurement photo upload", type: :feature do
  let(:user) do
    User.create!(
      email: "paul-#{SecureRandom.hex(4)}@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )
  end

  let(:profile) do
    Profile.create!(
      user: user,
      display_name: "Paul",
      unit_system: "imperial"
    )
  end

  let(:check_in) do
    profile.check_ins.create!(
      checked_in_on: Date.current,
      notes: "Weekly update"
    )
  end

  before do
    profile
    check_in
    log_in_with(email: user.email)
  end

  it "can create a new measurement with a body part photo" do
    visit new_profile_check_in_measurement_path(profile, check_in)

    select "Waist", from: "Body part"
    fill_in "Value", with: 34.5
    attach_file "Photo", Rails.root.join("spec/fixtures/files/back_photo.png")

    click_button "Create Measurement"

    measurement = Measurement.last

    expect(current_path).to eq(profile_check_in_path(profile, check_in))
    expect(page).to have_content("Measurement created successfully.")
    expect(measurement.body_part_photo).to be_attached
  end

  it "can update a measurement with a body part photo" do
    measurement = check_in.measurements.create!(
      body_part: "waist",
      value: 34.5
    )

    visit edit_profile_check_in_measurement_path(profile, check_in, measurement)

    attach_file "Photo", Rails.root.join("spec/fixtures/files/back_photo.png")
    click_button "Update Measurement"

    expect(current_path).to eq(profile_check_in_measurement_path(profile, check_in, measurement))
    expect(page).to have_content("Measurement updated successfully.")
    expect(measurement.reload.body_part_photo).to be_attached
    expect(page).to have_css("img")
  end
end