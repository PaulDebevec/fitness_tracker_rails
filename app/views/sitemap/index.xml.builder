xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  # Home page
  xml.url do
    xml.loc root_url
    xml.changefreq "daily"
    xml.priority 1.0
  end

  # Public profiles
  @profiles.each do |profile|
    xml.url do
      xml.loc profile_url(profile)
      xml.changefreq "weekly"
      xml.priority 0.8
    end
  end
end