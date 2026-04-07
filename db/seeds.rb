puts "Clearing existing data..."

Measurement.destroy_all
CheckIn.destroy_all
Profile.destroy_all

puts "Seeding profiles, check-ins, and measurements..."

def sample_notes
  [
    "Felt strong this week.",
    "Recovery week but staying consistent.",
    "Energy was better this check-in.",
    "Clothes are fitting differently.",
    "Workout intensity has improved.",
    "Nutrition has been more consistent lately."
  ].sample
end

def measurement_templates_for(unit)
  if unit == "cm"
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

def adjusted_value(body_part, base_value, index)
  trend = index * 0.2

  value =
    case body_part
    when "waist", "hips"
      base_value - trend
    when "weight"
      base_value - (index * 0.8)
    else
      base_value + trend
    end

  value.round(1)
end

def create_profile_with_history(display_name:, default_unit:)
  profile = Profile.create!(
    display_name: display_name,
    default_unit: default_unit
  )

  templates = measurement_templates_for(default_unit)

  6.times do |index|
    check_in = profile.check_ins.create!(
      checked_in_on: Date.current - ((5 - index) * 14),
      notes: sample_notes
    )

    Measurement::BODY_PARTS.each do |body_part|
      base_value = templates[body_part]

      check_in.measurements.create!(
        body_part: body_part,
        value: adjusted_value(body_part, base_value, index)
      )
    end
  end

  profile
end

create_profile_with_history(display_name: "Paul", default_unit: "in")
create_profile_with_history(display_name: "Jamie", default_unit: "in")
create_profile_with_history(display_name: "Taylor", default_unit: "cm")

puts "Done!"
puts "Profiles: #{Profile.count}"
puts "CheckIns: #{CheckIn.count}"
puts "Measurements: #{Measurement.count}"