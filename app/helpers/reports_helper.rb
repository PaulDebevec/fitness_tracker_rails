module ReportsHelper
    def chart_theme_options
      {
        scales: {
          x: {
            ticks: { color: chart_text_color },
            title: { color: chart_title_color },
            grid: { color: chart_grid_color }
          },
          y: {
            ticks: { color: chart_text_color },
            title: { color: chart_title_color },
            grid: { color: chart_grid_color }
          }
        },
        plugins: {
          legend: {
            labels: {
              color: chart_text_color
            }
          }
        }
      }
    end
  
    private
  
    def chart_text_color
      dark_theme? ? "#e5e7eb" : "#374151"
    end
  
    def chart_title_color
      dark_theme? ? "#f9fafb" : "#111827"
    end
  
    def chart_grid_color
      dark_theme? ? "rgba(229, 231, 235, 0.15)" : "rgba(107, 114, 128, 0.2)"
    end
  
    def dark_theme?
      return true if current_user&.profile&.theme_mode == "dark"
  
      false
    end
  end