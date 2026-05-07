# frozen_string_literal: true

class SitemapController < ApplicationController
  def index
    @profiles = Profile.where(public_profile: true)

    respond_to(&:xml)
  end
end
