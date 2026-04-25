class SettingsController < ApplicationController
    before_action :require_login
  
    def edit
      @user = current_user
      @profile = current_user.profile
    end
  
    def update
        @user = current_user
        @profile = current_user.profile
      
        user_attrs = user_params.dup
        current_password = user_attrs.delete(:current_password)
      
        requires_password =
          user_attrs[:email].present? && user_attrs[:email] != @user.email ||
          user_attrs[:password].present?
      
        if requires_password && !@user.authenticate(current_password)
          @user.errors.add(:current_password, "is incorrect")
          render :edit, status: :unprocessable_content
          return
        end
      
        if user_attrs[:password].blank?
          user_attrs.delete(:password)
          user_attrs.delete(:password_confirmation)
        end
      
        ActiveRecord::Base.transaction do
          @user.update!(user_attrs)
          @profile.update!(profile_params)
        end
      
        redirect_to profile_path(@profile), notice: "Settings updated successfully."
      rescue ActiveRecord::RecordInvalid
        render :edit, status: :unprocessable_content
      end
  
    private
  
    def user_params
      permitted = params.require(:user).permit(
        :email,
        :password,
        :password_confirmation,
        :current_password
      )
  
      if permitted[:password].blank?
        permitted.delete(:password)
        permitted.delete(:password_confirmation)
      end
  
      permitted
    end
  
    def profile_params
      params.require(:profile).permit(
        :display_name,
        :unit_system,
        :public_profile
      )
    end
end