class MeasurementReport
  TIMEFRAME_OPTIONS = {
    "30_days" => 30,
    "90_days" => 90,
    "6_months" => 180,
    "1_year" => 365,
    "all_time" => nil
  }.freeze

  BODY_PART_COLORS = {
    "weight" => "#2563eb",
    "chest" => "#dc2626",
    "waist" => "#059669",
    "hips" => "#7c3aed",
    "shoulders" => "#ea580c",
    "bicep_left" => "#0891b2",
    "bicep_right" => "#0d9488",
    "thigh_left" => "#9333ea",
    "thigh_right" => "#ca8a04"
  }.freeze

  attr_reader :profile, :body_part, :timeframe

  def initialize(profile:, body_part: nil, timeframe: "all_time")
    @profile = profile
    @body_part = normalize_body_part(body_part)
    @timeframe = normalize_timeframe(timeframe)
  end

  def measurements
    @measurements ||= filtered_measurements.order("check_ins.checked_in_on ASC, measurements.body_part ASC")
  end

  def measurements_grouped_by_body_part
    measurements.group_by(&:body_part)
  end

  def summary
    return grouped_summary if body_part.blank?
    single_body_part_summary
  end

  def chart_end_date
    measurements.map { |measurement| measurement.check_in.checked_in_on }.max
  end

  def chart_data
    extend_series_to_chart_end(
      measurements.sort_by { |measurement| measurement.check_in.checked_in_on }
    )
  end

  def weight_chart_data
    extend_series_to_chart_end(
      measurements.select { |measurement| measurement.body_part == "weight" }
                  .sort_by { |measurement| measurement.check_in.checked_in_on }
    )
  end

  def body_measurement_chart_data
    grouped = measurements_grouped_by_body_part.except("weight")
  
    Measurement::BODY_PARTS.filter_map do |body_part|
      next unless grouped[body_part]
  
      {
        name: body_part.humanize,
        color: BODY_PART_COLORS[body_part],
        data: extend_series_to_chart_end(
          grouped[body_part].sort_by { |measurement| measurement.check_in.checked_in_on }
        )
      }
    end
  end
  
  def weight_measurements_present?
    measurements_grouped_by_body_part["weight"].present?
  end
  
  def body_measurements_present?
    measurements_grouped_by_body_part.except("weight").any?
  end
  
  def max_chart_value_for(collection = measurements)
    return nil if collection.empty?
  
    highest = collection.map { |measurement| measurement.value.to_f }.max
    (highest + chart_padding).ceil(1)
  end
  
  def max_weight_chart_value
    max_chart_value_for(measurements.select { |measurement| measurement.body_part == "weight" })
  end
  
  def max_body_measurement_chart_value
    max_chart_value_for(measurements.reject { |measurement| measurement.body_part == "weight" })
  end

  def min_weight_chart_value
    weight_measurements = measurements.select { |m| m.body_part == "weight" }
    return nil if weight_measurements.empty?
  
    lowest = weight_measurements.map(&:value).map(&:to_f).min
    (lowest - chart_padding).floor
  end
  
  def min_body_measurement_chart_value
    body_measurements = measurements.reject { |m| m.body_part == "weight" }
    return nil if body_measurements.empty?
  
    lowest = body_measurements.map(&:value).map(&:to_f).min
    (lowest - chart_padding).floor
  end

  def max_chart_value
    return nil if measurements.empty?
  
    highest = measurements.map { |measurement| measurement.value.to_f }.max
    (highest + chart_padding).ceil(1)
  end

  def min_chart_value
    return nil if measurements.empty?
  
    lowest = measurements.map { |measurement| measurement.value.to_f }.min
    (lowest - chart_padding).floor
  end

  private

  def filtered_measurements
    scope = Measurement
      .includes(:check_in)
      .joins(:check_in)
      .where(check_ins: { profile_id: profile.id })

    scope = scope.for_body_part(body_part) if body_part.present?

    days = TIMEFRAME_OPTIONS[timeframe]

    if days.present?
      scope = scope.where("check_ins.checked_in_on >= ?", Date.current - days.days)
    end

    scope
  end

  def single_body_part_summary
    return empty_summary(body_part) if measurements.empty?

    values = measurements.map { |measurement| measurement.value.to_f }

    {
      body_part: body_part,
      timeframe: timeframe,
      count: measurements.count,
      start_date: measurements.first.check_in.checked_in_on,
      end_date: measurements.last.check_in.checked_in_on,
      starting_value: values.first,
      ending_value: values.last,
      change: (values.last - values.first).round(2),
      min: values.min,
      max: values.max,
      average: (values.sum / values.size).round(2)
    }
  end

  def grouped_summary
    grouped = measurements.group_by(&:body_part)

    grouped.transform_values do |body_part_measurements|
      values = body_part_measurements.map { |measurement| measurement.value.to_f }

      {
        body_part: body_part_measurements.first.body_part,
        timeframe: timeframe,
        count: body_part_measurements.count,
        start_date: body_part_measurements.first.check_in.checked_in_on,
        end_date: body_part_measurements.last.check_in.checked_in_on,
        starting_value: values.first,
        ending_value: values.last,
        change: (values.last - values.first).round(2),
        min: values.min,
        max: values.max,
        average: (values.sum / values.size).round(2)
      }
    end
  end

  def empty_summary(selected_body_part)
    {
      body_part: selected_body_part,
      timeframe: timeframe,
      count: 0,
      start_date: nil,
      end_date: nil,
      starting_value: nil,
      ending_value: nil,
      change: nil,
      min: nil,
      max: nil,
      average: nil
    }
  end

  def normalize_body_part(value)
    return nil if value.blank?
    return value if Measurement::BODY_PARTS.include?(value)

    nil
  end

  def normalize_timeframe(value)
    return value if TIMEFRAME_OPTIONS.key?(value)

    "all_time"
  end

  def series_for_body_part(body_part)
    body_part_measurements = measurements.select { |measurement| measurement.body_part == body_part }
  
    body_part_measurements
      .sort_by { |measurement| measurement.check_in.checked_in_on }
      .map { |measurement| [measurement.check_in.checked_in_on, measurement.value.to_f] }
  end

  def extend_series_to_chart_end(series_measurements)
    return [] if series_measurements.empty?
  
    points = series_measurements.map do |measurement|
      [measurement.check_in.checked_in_on, measurement.value.to_f]
    end
  
    last_date, last_value = points.last
    end_date = chart_end_date
  
    if end_date.present? && last_date < end_date
      points << [end_date, last_value]
    end
  
    points
  end
  
  def chart_padding
    0.5
  end
end
