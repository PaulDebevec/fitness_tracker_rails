puts "Clearing existing data..."

Measurement.destroy_all
CheckIn.destroy_all
Profile.destroy_all

puts "Seeding profiles, check-ins, measurements, and photos..."

SEED_IMAGE_PATHS = [
  Rails.root.join("spec/fixtures/files/back_photo.png"),
  Rails.root.join("spec/fixtures/files/front_photo.png"),
  Rails.root.join("spec/fixtures/files/side_photo.png")
].freeze

def sample_notes_for(profile_name)
  case profile_name
  when "Paul"
    [
      "Felt strong this week and recovery has been solid.",
      "Waist is trending down a bit and energy is stable.",
      "Upper body training felt good this check-in.",
      "Leg day was rough, but overall progress feels steady.",
      "Clothes are fitting a little differently this month.",
      "Recovery and sleep have both improved recently."
    ]
  when "Jamie"
    [
      "Consistency has been the main goal lately.",
      "Not a dramatic change this week, but staying on track.",
      "Measurements feel steady and workouts are improving.",
      "Energy dipped a little this week but still stayed consistent.",
      "Seeing some improvement in upper body measurements.",
      "Lower body work has been more consistent this month."
    ]
  when "Shaina"
    [
      "Progress is steady and motivation has been high.",
      "Nutrition has been more structured this check-in period.",
      "Measurements are changing slowly but consistently.",
      "Feeling stronger overall and posture feels better.",
      "Leg work has been a focus over the last few weeks.",
      "Recovery has been good and training volume is up."
    ]
  else
    [
      "Steady progress this week.",
      "Feeling consistent and focused."
    ]
  end
end

def measurement_templates_for(unit, profile_name)
  case [profile_name, unit]
  when ["Paul", "imperial"]
    {
      "weight" => 188.0,
      "chest" => 42.5,
      "waist" => 35.5,
      "hips" => 39.5,
      "shoulders" => 48.5,
      "bicep_left" => 15.2,
      "bicep_right" => 15.4,
      "thigh_left" => 23.4,
      "thigh_right" => 23.6
    }
  when ["Jamie", "imperial"]
    {
      "weight" => 172.0,
      "chest" => 39.5,
      "waist" => 33.0,
      "hips" => 38.0,
      "shoulders" => 45.0,
      "bicep_left" => 14.0,
      "bicep_right" => 14.1,
      "thigh_left" => 22.0,
      "thigh_right" => 22.2
    }
  when ["Shaina", "metric"]
    {
      "weight" => 81.0,
      "chest" => 104.0,
      "waist" => 87.0,
      "hips" => 98.0,
      "shoulders" => 121.0,
      "bicep_left" => 37.0,
      "bicep_right" => 37.4,
      "thigh_left" => 57.0,
      "thigh_right" => 57.5
    }
  else
    if unit == "metric"
      {
        "weight" => 84.0,
        "chest" => 107.0,
        "waist" => 89.0,
        "hips" => 99.0,
        "shoulders" => 122.0,
        "bicep_left" => 38.0,
        "bicep_right" => 38.5,
        "thigh_left" => 58.0,
        "thigh_right" => 58.3
      }
    else
      {
        "weight" => 185.0,
        "chest" => 42.0,
        "waist" => 35.0,
        "hips" => 39.0,
        "shoulders" => 48.0,
        "bicep_left" => 15.0,
        "bicep_right" => 15.2,
        "thigh_left" => 23.0,
        "thigh_right" => 23.1
      }
    end
  end
end

def adjusted_value(body_part, base_value, index, profile_name)
  drift =
    case body_part
    when "waist", "hips"
      -(index * 0.25)
    when "weight"
      -(index * 0.9)
    when "chest", "shoulders", "bicep_left", "bicep_right"
      index * 0.15
    when "thigh_left", "thigh_right"
      index * 0.1
    else
      0
    end

  profile_offset =
    case profile_name
    when "Paul" then 0.0
    when "Jamie" then 0.1
    when "Shaina" then 0.2
    else 0.0
    end

  (base_value + drift + profile_offset).round(1)
end

def measurement_set_for(index)
  case index
  when 0
    %w[weight waist chest]
  when 1
    %w[weight waist hips shoulders]
  when 2
    %w[weight chest bicep_left bicep_right]
  when 3
    %w[weight waist thigh_left thigh_right]
  when 4
    %w[weight chest shoulders waist hips]
  else
    %w[weight waist chest shoulders bicep_left thigh_left]
  end
end

def seed_photo_directories
  {
    front_photo: Rails.root.join("db/seed_files/front_photos"),
    back_photo: Rails.root.join("db/seed_files/back_photos"),
    side_photo: Rails.root.join("db/seed_files/side_photos"),
  }
end

def available_photo_sets
  sets = Hash.new { |hash, key| hash[key] = {} }

  seed_photo_directories.each do |attachment_name, directory|
    next unless Dir.exist?(directory)

    Dir.glob(directory.join("*.png")).each do |file_path|
      filename = File.basename(file_path, ".png")

      suffix =
        case attachment_name
        when :front_photo
          filename.delete_prefix("front_photo_")
        when :back_photo
          filename.delete_prefix("back_photo_")
        when :side_photo
          filename.delete_prefix("side_photo_")
        end

      sets[suffix][attachment_name] = file_path
    end
  end

  sets
end

def attach_photo_set(check_in, photo_set)
  photo_set.each do |attachment_name, file_path|
    next unless File.exist?(file_path)

    check_in.public_send(attachment_name).attach(
      io: File.open(file_path),
      filename: File.basename(file_path),
      content_type: "image/png"
    )
  end
end

def create_profile_with_history(display_name:, unit_system:, day_offsets:, photo_sets:, user:)
  profile = Profile.create!(
    display_name: display_name,
    unit_system: unit_system,
    user: user
  )

  notes = sample_notes_for(display_name)
  templates = measurement_templates_for(unit_system, display_name)

  day_offsets.each_with_index do |day_offset, index|
    check_in = profile.check_ins.create!(
      checked_in_on: Date.current - day_offset.days,
      notes: notes[index % notes.length]
    )

    measurement_set_for(index).each do |body_part|
      base_value = templates.fetch(body_part)

      check_in.measurements.create!(
        body_part: body_part,
        value: adjusted_value(body_part, base_value, index, display_name)
      )
    end

    photo_set = photo_sets[index % photo_sets.length]
    attach_photo_set(check_in, photo_set) if photo_set.present?
  end

  profile
end

photo_sets = available_photo_sets.values

user_1 = User.create!(
  email: "paul@example.com",
  password: "supersecure123",
  password_confirmation: "supersecure123",
  role: "user"
)

create_profile_with_history(
  display_name: "Paul",
  unit_system: "imperial",
  day_offsets: [84, 63, 49, 35, 14, 3],
  photo_sets: photo_sets,
  user: user_1
)

user_2 = User.create!(
  email: "jamie@example.com",
  password: "supersecure123",
  password_confirmation: "supersecure123",
  role: "user"
)

create_profile_with_history(
  display_name: "Jamie",
  unit_system: "imperial",
  day_offsets: [90, 70, 52, 28, 12, 1],
  photo_sets: photo_sets.rotate(1),
  user: user_2
)

user_3 = User.create!(
  email: "sHaiNa@exaMPle.com",
  password: "supersecure123",
  password_confirmation: "supersecure123",
  role: "user"
)

create_profile_with_history(
  display_name: "Shaina",
  unit_system: "metric",
  day_offsets: [95, 74, 58, 41, 19, 6],
  photo_sets: photo_sets.rotate(2),
  user: user_3
)

available_photo_sets.each do |suffix, files|
  puts "#{suffix}: #{files.keys.join(", ")}"
end
puts "Discovered #{photo_sets.length} photo sets for check-in attachments"

puts "Done!"
puts "Profiles: #{Profile.count}"
puts "CheckIns: #{CheckIn.count}"
puts "Measurements: #{Measurement.count}"
puts "CheckIns with photos:"
puts "  Front photos: #{CheckIn.all.count { |c| c.front_photo.attached? }}"
puts "  Back photos: #{CheckIn.all.count { |c| c.back_photo.attached? }}"
puts "  Side photos: #{CheckIn.all.count { |c| c.side_photo.attached? }}"