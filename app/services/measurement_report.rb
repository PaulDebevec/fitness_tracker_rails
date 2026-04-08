class MeasurementReport
  TIMEFRAME_OPTIONS = {
    "30_days" => 30,
    "90_days" => 90,
    "6_months" => 180,
    "1_year" => 365,
    "all_time" => nil
  }.freeze

  attr_reader :profile, :body_part, :timeframe

  def initialize(profile:, body_part: nil, timeframe: "all_time")
    @profile = profile
    @body_part = body_part.presence
    @timeframe = timeframe
  end

  def measurements
    @measurements ||= filtered_measurements.order("check_ins.checked_in_on ASC, measurements.body_part ASC")
  end

  def chart_data
    measurements.map do |measurement|
      {
        body_part: measurement.body_part,
        date: measurement.check_in.checked_in_on,
        value: measurement.value.to_f
      }
    end
  end

  def summary
    return grouped_summary if body_part.blank?
    single_body_part_summary
  end

  def measurements_grouped_by_body_part
    measurements.group_by(&:body_part)
  end

  private

  def filtered_measurements
    scope = Measurement
      .includes(:check_in)
      .joins(:check_in)
      .where(check_ins: { profile_id: profile.id })

    scope = scope.where(body_part: body_part) if body_part.present?

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
end