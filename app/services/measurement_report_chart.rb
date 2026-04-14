class MeasurementReportChart
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
  
    attr_reader :report
  
    def initialize(report:)
      @report = report
    end
  
    def chart_end_date
      report.measurements.map { |measurement| measurement.check_in.checked_in_on }.max
    end
  
    def chart_data
      extend_series_to_chart_end(
        report.measurements.sort_by { |measurement| measurement.check_in.checked_in_on }
      )
    end
  
    def weight_chart_data
      extend_series_to_chart_end(
        report.measurements.select { |measurement| measurement.body_part == "weight" }
                          .sort_by { |measurement| measurement.check_in.checked_in_on }
      )
    end
  
    def body_measurement_chart_data
      grouped = report.measurements_grouped_by_body_part.except("weight")
  
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
  
    def body_measurement_change_chart_data
      grouped = report.measurements_grouped_by_body_part.except("weight")
  
      Measurement::BODY_PARTS.filter_map do |body_part|
        next unless grouped[body_part]
  
        sorted_measurements = grouped[body_part].sort_by { |measurement| measurement.check_in.checked_in_on }
        next if sorted_measurements.empty?
  
        baseline_value = sorted_measurements.first.value.to_f
        previous_value = nil
  
        series_data = sorted_measurements.map do |measurement|
          current_value = measurement.value.to_f
  
          change =
            case report.change_mode
            when "starting"
              (current_value - baseline_value).round(2)
            else
              previous_value.nil? ? 0.0 : (current_value - previous_value).round(2)
            end
  
          previous_value = current_value
  
          [measurement.check_in.checked_in_on, change]
        end
  
        {
          name: body_part.humanize,
          color: BODY_PART_COLORS[body_part],
          data: series_data
        }
      end
    end
  
    def weight_measurements_present?
      report.measurements_grouped_by_body_part["weight"].present?
    end
  
    def body_measurements_present?
      report.measurements_grouped_by_body_part.except("weight").any?
    end
  
    def max_chart_value
      max_chart_value_for(report.measurements)
    end
  
    def min_chart_value
      min_chart_value_for(report.measurements)
    end
  
    def max_weight_chart_value
      max_chart_value_for(report.measurements.select { |measurement| measurement.body_part == "weight" })
    end
  
    def min_weight_chart_value
      min_chart_value_for(report.measurements.select { |measurement| measurement.body_part == "weight" })
    end
  
    def max_body_measurement_chart_value
      max_chart_value_for(report.measurements.reject { |measurement| measurement.body_part == "weight" })
    end
  
    def min_body_measurement_chart_value
      min_chart_value_for(report.measurements.reject { |measurement| measurement.body_part == "weight" })
    end
  
    def min_body_measurement_change_chart_value
      values = body_measurement_change_values
      return nil if values.empty?
  
      lowest = values.min
      [lowest - change_chart_padding, 0].min.floor
    end
  
    def max_body_measurement_change_chart_value
      values = body_measurement_change_values
      return nil if values.empty?
  
      highest = values.max
      [highest + change_chart_padding, 0].max.ceil
    end
  
    def formatted_change_mode
      case report.change_mode
      when "starting"
        "Since First Check-in"
      else
        "Since Previous Check-in"
      end
    end
  
    private
  
    def max_chart_value_for(collection)
      return nil if collection.empty?
  
      highest = collection.map { |measurement| measurement.value.to_f }.max
      (highest + chart_padding).ceil(1)
    end
  
    def min_chart_value_for(collection)
      return nil if collection.empty?
  
      lowest = collection.map { |measurement| measurement.value.to_f }.min
      (lowest - chart_padding).floor
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
  
    def body_measurement_change_values
      body_measurement_change_chart_data.flat_map do |series|
        series[:data].map { |(_, value)| value.to_f }
      end
    end
  
    def chart_padding
      0.5
    end
  
    def change_chart_padding
      0.5
    end
  end