require "rails_helper"

RSpec.describe "Report", type: :feature do
  describe "progress reporting" do
    let(:profile) do
      Profile.create!(display_name: "Paul", default_unit: "in")
    end

    let!(:older_check_in) do
      profile.check_ins.create!(
        checked_in_on: Date.current - 60.days,
        notes: "Older check-in"
      )
    end

    let!(:recent_check_in) do
      profile.check_ins.create!(
        checked_in_on: Date.current - 7.days,
        notes: "Recent check-in"
      )
    end

    let!(:older_waist) do
      older_check_in.measurements.create!(body_part: "waist", value: 36.0)
    end

    let!(:recent_waist) do
      recent_check_in.measurements.create!(body_part: "waist", value: 34.0)
    end

    let!(:recent_chest) do
      recent_check_in.measurements.create!(body_part: "chest", value: 42.0)
    end

    it "allows a user to view the progress report page" do
      visit profile_path(profile)
      click_link "View Progress Report"

      expect(current_path).to eq(profile_report_path(profile))
      expect(page).to have_content("Paul Progress Report")
    end

    it "shows summary and history together for each body part when no body part is selected" do
        visit profile_report_path(profile)
      
        expect(page).to have_content("Waist")
        expect(page).to have_content("Entries:")
        expect(page).to have_content("History")
        expect(page).to have_content("36.0")
        expect(page).to have_content("34.0")
      
        expect(page).to have_content("Chest")
        expect(page).to have_content("42.0")
      end

    it "filters the report by body part" do
      visit profile_report_path(profile)

      select "Waist", from: "Body Part"
      click_button "Run Report"

      expect(page).to have_content("Waist")
      expect(page).to have_content("36.0")
      expect(page).to have_content("34.0")
      expect(page).not_to have_content("42.0")
    end

    it "filters the report by timeframe" do
      visit profile_report_path(profile)

      select "Waist", from: "Body Part"
      select "30 days", from: "Timeframe"
      click_button "Run Report"

      expect(page).to have_content("34.0")
      expect(page).not_to have_content("36.0")
    end

    it "shows an export csv link" do
      visit profile_report_path(profile)
      expect(page).to have_link("Export CSV")
    end
  end
end