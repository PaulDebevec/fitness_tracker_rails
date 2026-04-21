class UsersController < ApplicationController
    def new
      @user = User.new
      @profile = Profile.new
    end
  
    def create
      @user = User.new(user_params)
      @profile = @user.build_profile(profile_params)
  
      ActiveRecord::Base.transaction do
        @user.save!
        @profile.save!
      end
      
      reset_session
      session[:user_id] = @user.id
  
      redirect_to profile_path(@user.profile), notice: "Account created successfully."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_content
    end
  
    private
  
    def user_params
      params.require(:user).permit(
        :email,
        :password,
        :password_confirmation
      )
    end
  
    def profile_params
      params.require(:profile).permit(
        :display_name,
        :unit_system
      )
    end
end