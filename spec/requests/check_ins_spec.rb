require "rails_helper"

RSpec.describe "CheckIns", type: :request do
  let!(:profile) { Profile.create!(display_name: "Paul", default_unit: "in") }

  describe "GET /profiles/:profile_id/check_ins" do
    it "returns http success" do
      get profile_check_ins_path(profile)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /profiles/:profile_id/check_ins/new" do
    it "returns http success" do
      get new_profile_check_in_path(profile)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /profiles/:profile_id/check_ins" do
    context "with valid params" do
      it "creates a check-in and redirects to the show page" do
        expect {
          post profile_check_ins_path(profile), params: {
            check_in: {
              checked_in_on: Date.current,
              notes: "Created via request spec"
            }
          }
        }.to change(CheckIn, :count).by(1)

        check_in = CheckIn.last
        expect(response).to redirect_to(profile_check_in_path(profile, check_in))
      end
    end

    context "with invalid params" do
      it "does not create a check-in without a date" do
        expect {
          post profile_check_ins_path(profile), params: {
            check_in: {
              checked_in_on: "",
              notes: "Invalid"
            }
          }
        }.not_to change(CheckIn, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create a check-in with a future date" do
        expect {
          post profile_check_ins_path(profile), params: {
            check_in: {
              checked_in_on: Date.current + 1.day,
              notes: "Future"
            }
          }
        }.not_to change(CheckIn, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /profiles/:profile_id/check_ins/:id" do
    it "returns http success" do
      check_in = profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Show page"
      )

      get profile_check_in_path(profile, check_in)
      expect(response).to have_http_status(:ok)
    end

    it "redirects when the check-in does not exist" do
      get "/profiles/#{profile.id}/check_ins/999999"

      expect(response).to redirect_to(profile_check_ins_path(profile))
    end
  end

  describe "GET /profiles/:profile_id/check_ins/:id/edit" do
    it "returns http success" do
      check_in = profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Edit page"
      )

      get edit_profile_check_in_path(profile, check_in)
      expect(response).to have_http_status(:ok)
    end

    it "redirects when the check-in does not exist" do
      get "/profiles/#{profile.id}/check_ins/999999/edit"

      expect(response).to redirect_to(profile_check_ins_path(profile))
    end
  end

  describe "PATCH /profiles/:profile_id/check_ins/:id" do
    let!(:check_in) do
      profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Original note"
      )
    end

    context "with valid params" do
      it "updates the check-in and redirects to the show page" do
        patch profile_check_in_path(profile, check_in), params: {
          check_in: {
            checked_in_on: Date.current,
            notes: "Updated note"
          }
        }

        expect(response).to redirect_to(profile_check_in_path(profile, check_in))
        expect(check_in.reload.notes).to eq("Updated note")
      end
    end

    context "with invalid params" do
      it "does not update the check-in with a blank date" do
        patch profile_check_in_path(profile, check_in), params: {
          check_in: {
            checked_in_on: "",
            notes: "Updated note"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(check_in.reload.checked_in_on).to eq(Date.current)
      end
    end
  end

  describe "DELETE /profiles/:profile_id/check_ins/:id" do
    it "deletes the check-in and redirects to the index page" do
      check_in = profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Delete me"
      )

      expect {
        delete profile_check_in_path(profile, check_in)
      }.to change(CheckIn, :count).by(-1)

      expect(response).to redirect_to(profile_check_ins_path(profile))
    end

    it "redirects when deleting a non-existent check-in" do
      delete "/profiles/#{profile.id}/check_ins/999999"

      expect(response).to redirect_to(profile_check_ins_path(profile))
    end
  end
end