require "rails_helper"

RSpec.describe "Measurements", type: :request do
  let!(:profile) { Profile.create!(display_name: "Paul", default_unit: "in") }
  let!(:check_in) { profile.check_ins.create!(checked_in_on: Date.current, notes: "Weekly update") }

  describe "GET /profiles/:profile_id/check_ins/:check_in_id/measurements" do
    it "returns http success" do
      get profile_check_in_measurements_path(profile, check_in)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /profiles/:profile_id/check_ins/:check_in_id/measurements/new" do
    it "returns http success" do
      get new_profile_check_in_measurement_path(profile, check_in)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /profiles/:profile_id/check_ins/:check_in_id/measurements" do
    context "with valid params" do
      it "creates a measurement and redirects to the show page" do
        expect {
          post profile_check_in_measurements_path(profile, check_in), params: {
            measurement: {
              body_part: "waist",
              value: 34.5
            }
          }
        }.to change(Measurement, :count).by(1)

        measurement = Measurement.last
        expect(response).to redirect_to(profile_check_in_measurement_path(profile, check_in, measurement))
      end
    end

    context "with invalid params" do
      it "does not create a measurement without a body part" do
        expect {
          post profile_check_in_measurements_path(profile, check_in), params: {
            measurement: {
              body_part: "",
              value: 34.5
            }
          }
        }.not_to change(Measurement, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a measurement without a value" do
        expect {
          post profile_check_in_measurements_path(profile, check_in), params: {
            measurement: {
              body_part: "waist",
              value: nil
            }
          }
        }.not_to change(Measurement, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end