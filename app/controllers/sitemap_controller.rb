class SitemapController < ApplicationController
    def index
      @profiles = Profile.where(public_profile: true)
  
      respond_to do |format|
        format.xml
      end
    end
  end