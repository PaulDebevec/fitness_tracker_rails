class ProfilePhotoTimeline
    PHOTO_TYPES = %w[front_photo side_photo back_photo].freeze
  
    attr_reader :profile, :photo_type
  
    def initialize(profile:, photo_type: "front_photo")
      @profile = profile
      @photo_type = normalize_photo_type(photo_type)
    end
  
    def photos
      @photos ||= begin
        profile.check_ins
          .chronological
          .select { |check_in| check_in.public_send(photo_type).attached? }
          .map do |check_in|
            {
              check_in_id: check_in.id,
              checked_in_on: check_in.checked_in_on,
              formatted_date: check_in.formatted_date,
              attachment: check_in.public_send(photo_type)
            }
          end
      end
    end
  
    def any_photos?
      photos.any?
    end
  
    def oldest_photo
      photos.first
    end
  
    def newest_photo
      photos.last
    end
  
    def photo_type_label
      photo_type.delete_suffix("_photo").humanize
    end

    def comparable?
        photos.size >= 2
    end
  
    private
  
    def normalize_photo_type(value)
      return value if PHOTO_TYPES.include?(value)
  
      "front_photo"
    end
  end