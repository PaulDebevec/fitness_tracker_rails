require "rails_helper"

RSpec.describe "Measurements", type: :request do
  let!(:user) { 
    User.create!(email: "viewer@example.com", 
    password: "supersecure123", 
    password_confirmation: "supersecure123",
    role: "user") 
  }
  let!(:profile) { Profile.create!(user: user, display_name: "Paul", unit_system: "imperial") }
  let!(:check_in) { profile.check_ins.create!(checked_in_on: Date.current, notes: "Weekly update") }

  before(:each) do
    log_in_as(user)
    user.mark_email_as_verified!
  end

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
        expect(response).to redirect_to(profile_check_in_path(profile, check_in))
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

  describe "GET /profiles/:profile_id/check_ins/:check_in_id/measurements/:id" do
    it "returns http success" do
      measurement = check_in.measurements.create!(body_part: "waist", value: 34.5)

      get profile_check_in_measurement_path(profile, check_in, measurement)

      expect(response).to have_http_status(:ok)
    end

    it "redirects when the measurement does not exist" do
      get "/profiles/#{profile.id}/check_ins/#{check_in.id}/measurements/999999"

      expect(response).to redirect_to(profile_check_in_measurements_path(profile, check_in))
    end
  end

  describe "GET /profiles/:profile_id/check_ins/:check_in_id/measurements/:id/edit" do
    it "returns http success" do
      measurement = check_in.measurements.create!(body_part: "waist", value: 34.5)

      get edit_profile_check_in_measurement_path(profile, check_in, measurement)

      expect(response).to have_http_status(:ok)
    end

    it "redirects when the measurement does not exist" do
      get "/profiles/#{profile.id}/check_ins/#{check_in.id}/measurements/999999/edit"

      expect(response).to redirect_to(profile_check_in_measurements_path(profile, check_in))
    end
  end

  describe "PATCH /profiles/:profile_id/check_ins/:check_in_id/measurements/:id" do
    let!(:measurement) do
      check_in.measurements.create!(body_part: "waist", value: 34.5)
    end

    context "with valid params" do
      it "updates the measurement and redirects to the show page" do
        patch profile_check_in_measurement_path(profile, check_in, measurement), params: {
          measurement: {
            body_part: "chest",
            value: 42.0
          }
        }

        expect(response).to redirect_to(profile_check_in_measurement_path(profile, check_in, measurement))
        expect(measurement.reload.body_part).to eq("chest")
        expect(measurement.reload.value.to_f).to eq(42.0)
      end
    end

    context "with invalid params" do
      it "does not update the measurement with a blank value" do
        patch profile_check_in_measurement_path(profile, check_in, measurement), params: {
          measurement: {
            body_part: "waist",
            value: nil
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(measurement.reload.value.to_f).to eq(34.5)
      end
    end
  end

  describe "DELETE /profiles/:profile_id/check_ins/:check_in_id/measurements/:id" do
    it "deletes the measurement and redirects to the index page" do
      measurement = check_in.measurements.create!(body_part: "waist", value: 34.5)

      expect {
        delete profile_check_in_measurement_path(profile, check_in, measurement)
      }.to change(Measurement, :count).by(-1)

      expect(response).to redirect_to(profile_check_in_measurements_path(profile, check_in))
    end

    it "redirects when deleting a non-existent measurement" do
      delete "/profiles/#{profile.id}/check_ins/#{check_in.id}/measurements/999999"

      expect(response).to redirect_to(profile_check_in_measurements_path(profile, check_in))
    end
  end

  describe "measurement" do
    it "creates a measurement with a body part photo" do
      image = test_image_upload("front_photo.png")
    
      post profile_check_in_measurements_path(profile, check_in), params: {
        measurement: {
          body_part: "waist",
          value: 34.5,
          body_part_photo: image
        }
      }
    
      measurement = Measurement.last
      expect(response).to redirect_to(profile_check_in_path(profile, check_in))
      expect(measurement.body_part_photo).to be_attached
    end
  end
end