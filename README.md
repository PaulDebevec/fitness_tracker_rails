# Fitness Progression Tracker

A web application designed to help users track **bodily changes over time** through measurements, progress photos, and interactive visual reports.

This app focuses on turning raw check-in data into **clear, meaningful insights** through charts and summaries, making it easy to monitor progress and trends.

---

## Table of Contents

- [About](#about)
    - [Goals](#goals)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Usage](#usage)
- [Testing](#testing)
- [Architecture](#architecture)
- [Future Improvements](#future-improvements)

---

## About

BodMetriks allows users to:

- Create an account  
- Log check-ins over time  
- Record body measurements and weight  
- Upload progress photos  
- Generate interactive reports with charts  

The goal is to provide a **simple but powerful way to visualize physical progress**, rather than relying on isolated data points.

---

## Goals

This project was built as a **personal portfolio application** with the following goals:

- Practice building a full-stack Rails application from the ground up  
- Reinforce RESTful design and MVC architecture  
- Improve test coverage using RSpec and Capybara  
- Explore data visualization using Chartkick / Chart.js  
- Implement clean UI/UX patterns with responsive design  
- Apply object-oriented design principles (e.g., service objects, separation of concerns)  

A key focus was building a **maintainable and extensible codebase**, not just a functional app.

This project is part of a larger effort to practice full-stack development across multiple technologies by implementing the same application in several stacks:

- Ruby on Rails monolyth with ERB (HTML/CSS/Minor JS) Front-End
- C# 
- Python / Flask Back-end API
- Golang Back-end API
- React / Angular Front-end to consume backend API's

Each version will implement the same core functionality and testing patterns.

---

## Features

### Core Features

- Profile creation and management  
- Check-in tracking with notes and timestamps  
- Measurement tracking (weight + body parts)  
- Progress photo uploads (ActiveStorage)  

### Reporting & Visualization

- Interactive charts:
  - Weight progress  
  - Body measurement trends (multi-series)  
  - Change over time (delta charts)  

- Toggle between:
  - Change since previous check-in  
  - Change since first check-in  

- Dynamic Y-axis scaling for improved readability  
- CSV export for report data  

### UX Enhancements

- Mobile-responsive design  
- Clickable cards for intuitive navigation  
- Turbo Frame updates for smoother interactions  
- Chart animations for visual feedback  

---

## Tech Stack

### Backend

- Ruby on Rails  
- PostgreSQL  

### Frontend

- ERB  
- CSS (custom styling)  
- Turbo (Hotwire)  

### Charts & Visualization

- Chartkick  
- Chart.js  

### Testing

- RSpec  
- Capybara  

### Other

- ActiveStorage (file uploads)  

---

## Installation

### Prerequisites

- Ruby (>= 3.x)  
- Rails (>= 7.x)  
- PostgreSQL  

### Setup

Clone the repository:
```sh
git clone https://github.com/your_username/fitness_tracker_rails.git
cd fitness_tracker_rails
```
Install dependencies:

`bundle install`  

Set up the database:
```sh
rails db:create  
rails db:migrate  
rails db:seed  
```
Start the server:

`rails server` 

Visit:

`http://localhost:3000` 

---

## Usage

1. Create a profile  
2. Add check-ins over time  
3. Record measurements and upload photos  
4. Navigate to the **Report page** to:
   - View trends  
   - Analyze changes  
   - Export data  

---

## Testing

Run the full test suite:

`bundle exec rspec`  

Run a specific file:

`bundle exec rspec spec/services/measurement_report_chart_spec.rb`  

Run feature specs:

`bundle exec rspec spec/features`  

---

## Architecture

This project follows standard Rails MVC patterns with additional service objects for clarity and separation of concerns.

### Key Design Decisions

- **Service Objects**
  - MeasurementReport → handles filtering, grouping, and summaries  
  - MeasurementReportChart → handles chart data and visualization logic  

- **Separation of Concerns**
  - Business logic is kept out of views  
  - Chart-specific logic is isolated from report logic  

- **Turbo Frames**
  - Used to update charts dynamically without full page reloads  

- **Test Coverage**
  - Feature tests for user flows  
  - Service tests for business logic  

---

## Future Improvements

- Add user authentication (multi-user support)
- Implement metric system conversion (kg/cm)
- Add goal tracking and progress benchmarks
- Improve chart interactivity (tooltips, comparisons)
- Add workout tracking
- Add meal planning nutrient tracking
- Add background jobs for large report generation
