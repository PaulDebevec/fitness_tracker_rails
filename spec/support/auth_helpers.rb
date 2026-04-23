module AuthHelpers
    def log_in_as(user, password: "supersecure123")
      post login_path, params: {
        email: user.email,
        password: password
      }
    end
end