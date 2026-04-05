# db/seeds.rb

puts "Clearing existing data..."
Measurement.destroy_all
CheckIn.destroy_all
Profile.destroy_all

puts "Seeding profiles, check-ins, and measurements..."

profiles_data = [
  {
    display_name: "Paul",
    default_unit: "in"
  },
  {
    display_name: "JP",
    default_unit: "cm"
  },
  {
    display_name: "Pat",
    default_unit: "in"
  }
]

measurement_templates = {
  "in" => {
    "weight" => 185.0,
    "chest" => 42.0,
    "waist" => 35.0,
    "hips" => 39.0,
    "shoulders" => 48.0,
    "bicep_left" => 15.0,
    "bicep_right" => 15.2,
    "thigh_left" => 23.0,
    "thigh_right" => 23.1
  },
  "cm" => {
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
}

profiles_data.each_with_index do |profile_data, profile_index|
  profile = Profile.create!(profile_data)
  base_values = measurement_templates[profile.default_unit]

  6.times do |i|
    check_in_date = Date.current - ((5 - i) * 14) # every two weeks
    check_in = profile.check_ins.create!(
      checked_in_on: check_in_date,
      notes: "Seeded check-in ##{i + 1} for #{profile.display_name}"
    )

    Measurement::BODY_PARTS.each_with_index do |body_part, body_part_index|
      base_value = base_values[body_part]

      # Add slight variance so the data looks natural over time
      trend_adjustment = i * 0.2
      random_adjustment = ((profile_index + body_part_index) % 3) * 0.1

      value =
        if body_part == "waist" || body_part == "hips"
          base_value - trend_adjustment + random_adjustment
        elsif body_part == "weight"
          base_value - (i * 0.8) + random_adjustment
        else
          base_value + trend_adjustment + random_adjustment
        end

      check_in.measurements.create!(
        body_part: body_part,
        value: value.round(1)
      )
    end
  end
end

puts "Done!"
puts "Created #{Profile.count} profiles"
puts "Created #{CheckIn.count} check-ins"
puts "Created #{Measurement.count} measurements"