require "rails_helper"

RSpec.describe "Home", type: :request do
    it "loads the home page" do
        get"/"
        expect(response).to have_http_status(:ok)
    end
end
