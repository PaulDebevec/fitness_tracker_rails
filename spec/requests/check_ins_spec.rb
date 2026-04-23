require "rails_helper"

RSpec.describe "CheckIns", type: :request do
  before(:each) do
    @private_owner = User.create!(
      email: "private_owner@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @public_owner = User.create!(
      email: "public_owner@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @non_owner = User.create!(
      email: "viewer@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "user"
    )

    @admin = User.create!(
      email: "admin@example.com",
      password: "supersecure123",
      password_confirmation: "supersecure123",
      role: "admin"
    )

    @non_owner_profile = Profile.create!(
      user: @non_owner,
      display_name: "Owner",
      unit_system: "imperial",
      public_profile: false
    )

    @admin_profile = Profile.create!(
      user: @admin,
      display_name: "Owner",
      unit_system: "imperial",
      public_profile: false
    )

    @private_profile = Profile.create!(
      user: @private_owner,
      display_name: "Owner",
      unit_system: "imperial",
      public_profile: false
    )

    @public_profile = Profile.create!(
      user: @public_owner,
      display_name: "Public Owner",
      unit_system: "imperial",
      public_profile: true
    )
  end

  describe "GET /profiles/:profile_id/check_ins" do
    before(:each) do
      @public_profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Public check-in"
      )
    end

    it "returns http success for a guest viewing a public profile" do
      get profile_check_ins_path(@public_profile)
      expect(response).to have_http_status(:ok)
    end

    it "redirects a guest viewing a private profile" do
      get profile_check_ins_path(@private_profile)
      expect(response).to redirect_to(root_path)
    end

    it "returns http success for the owner viewing their private profile" do
      log_in_as(@private_owner)

      get profile_check_ins_path(@private_profile)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /profiles/:profile_id/check_ins/new" do
    it "redirects guests to login" do
      get new_profile_check_in_path(@private_profile)
      expect(response).to redirect_to(login_path)
    end

    it "returns http success for the owner" do
      log_in_as(@private_owner)

      get new_profile_check_in_path(@private_profile)
      expect(response).to have_http_status(:ok)
    end

    it "redirects a non-owner user" do
      log_in_as(@non_owner)

      get new_profile_check_in_path(@private_profile)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /profiles/:profile_id/check_ins" do
    context "as the owner" do
      before(:each) do
        log_in_as(@private_owner)
      end

      context "with valid params" do
        it "creates a check-in and redirects to the show page" do
          expect {
            post profile_check_ins_path(@private_profile), params: {
              check_in: {
                checked_in_on: Date.current,
                notes: "Created via request spec"
              }
            }
          }.to change(CheckIn, :count).by(1)

          check_in = CheckIn.last
          expect(response).to redirect_to(profile_check_in_path(@private_profile, check_in))
        end
      end

      context "with invalid params" do
        it "does not create a check-in without a date" do
          expect {
            post profile_check_ins_path(@private_profile), params: {
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
            post profile_check_ins_path(@private_profile), params: {
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

    it "redirects guests to login" do
      post profile_check_ins_path(@private_profile), params: {
        check_in: {
          checked_in_on: Date.current,
          notes: "Guest attempt"
        }
      }

      expect(response).to redirect_to(login_path)
    end
  end

  describe "GET /profiles/:profile_id/check_ins/:id" do
    before(:each) do
      @public_check_in = @public_profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Show page"
      )

      @private_check_in = @private_profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Private show page"
      )
    end

    it "returns http success for a guest viewing a public profile check-in" do
      get profile_check_in_path(@public_profile, @public_check_in)
      expect(response).to have_http_status(:ok)
    end

    it "redirects a guest viewing a private profile check-in" do
      get profile_check_in_path(@private_profile, @private_check_in)
      expect(response).to redirect_to(root_path)
    end

    it "returns http success for the owner viewing their private profile check-in" do
      log_in_as(@private_owner)

      get profile_check_in_path(@private_profile, @private_check_in)
      expect(response).to have_http_status(:ok)
    end

    it "redirects when the check-in does not exist" do
      log_in_as(@public_owner)

      get "/profiles/#{@private_profile.id}/check_ins/999999"
      expect(response).to redirect_to(profile_check_ins_path(@private_profile))
    end
  end

  describe "GET /profiles/:profile_id/check_ins/:id/edit" do
    before(:each) do
      @check_in = @private_profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Edit page"
      )
    end

    it "redirects guests to login" do
      get edit_profile_check_in_path(@private_profile, @check_in)
      expect(response).to redirect_to(login_path)
    end

    it "returns http success for the owner" do
      log_in_as(@private_owner)

      get edit_profile_check_in_path(@private_profile, @check_in)
      expect(response).to have_http_status(:ok)
    end

    it "redirects a non-owner user" do
      log_in_as(@non_owner)

      get edit_profile_check_in_path(@private_profile, @check_in)
      expect(response).to redirect_to(root_path)
    end

    it "redirects when the check-in does not exist" do
      log_in_as(@public_owner)

      get "/profiles/#{@private_profile.id}/check_ins/999999/edit"
      expect(response).to redirect_to(profile_check_ins_path(@private_profile))
    end
  end

  describe "PATCH /profiles/:profile_id/check_ins/:id" do
    before(:each) do
      @check_in = @private_profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Original note"
      )
    end

    context "as the owner" do
      context "with valid params" do
        it "updates the check-in and redirects to the show page" do
          log_in_as(@private_owner)
          patch profile_check_in_path(@private_profile, @check_in), params: {
            check_in: {
              checked_in_on: Date.current,
              notes: "Updated note"
            }
          }

          expect(response).to redirect_to(profile_check_in_path(@private_profile, @check_in))
          expect(@check_in.reload.notes).to eq("Updated note")
        end
      end

      context "with invalid params" do
        it "does not update the check-in with a blank date" do
          log_in_as(@private_owner)
          patch profile_check_in_path(@private_profile, @check_in), params: {
            check_in: {
              checked_in_on: "",
              notes: "Updated note"
            }
          }

          expect(response).to have_http_status(:unprocessable_content)
          expect(@check_in.reload.checked_in_on).to eq(Date.current)
        end
      end
    end

    it "redirects guests to login" do
      patch profile_check_in_path(@private_profile, @check_in), params: {
        check_in: {
          checked_in_on: Date.current,
          notes: "Guest update"
        }
      }

      expect(response).to redirect_to(login_path)
    end
  end

  describe "DELETE /profiles/:profile_id/check_ins/:id" do
    before(:each) do
      @check_in = @private_profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Delete me"
      )

      @check_in_pub = @public_profile.check_ins.create!(
        checked_in_on: Date.current,
        notes: "Delete me"
      )
    end

    it "deletes the check-in and redirects to the index page for the owner" do
      log_in_as(@private_owner)

      expect {
        delete profile_check_in_path(@private_profile, @check_in)
      }.to change(CheckIn, :count).by(-1)

      expect(response).to redirect_to(profile_check_ins_path(@private_profile))
    end

    it "redirects when deleting a non-existent check-in" do
      log_in_as(@public_owner)

      delete "/profiles/#{@public_profile.id}/check_ins/9999999999999"
      expect(response).to redirect_to(profile_check_ins_path(@public_profile))
    end
  end

  describe "check-in photo upload" do
    it "creates a check-in with a front photo for the owner" do
      log_in_as(@public_owner)
      image = test_image_upload("front_photo.png")

      post profile_check_ins_path(@public_profile), params: {
        check_in: {
          checked_in_on: Date.current,
          notes: "With photo",
          front_photo: image
        }
      }

      check_in = CheckIn.last
      expect(response).to redirect_to(profile_check_in_path(@public_profile, check_in))
      expect(check_in.front_photo).to be_attached
    end
  end
end