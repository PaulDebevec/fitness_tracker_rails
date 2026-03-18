class CheckInsController < ApplicationController
  def index
    @profile = Profile.find(params[:profile_id])
  end
end
