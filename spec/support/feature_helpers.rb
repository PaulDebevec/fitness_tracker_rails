module FeatureHelpers
    def log_in_with(email:, password: "supersecure123")
      visit login_path
      fill_in "Email", with: email
      fill_in "Password", with: password
      click_button "Log In"
    end
end