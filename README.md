# Fitness Tracker (Rails)

A Ruby on Rails application for tracking fitness progress over time.  
This project is part of a larger effort to practice full-stack development across multiple technologies by implementing the same application in several stacks:

- Ruby on Rails
- Python / Flask
- Golang
- C#
- React / Angular

Each version will implement the same core functionality and testing patterns.

The Rails version currently includes full CRUD functionality for **Profiles**, which serve as the container for future fitness tracking data such as **Check-ins, measurements, and progress photos**.

---

# Current Features

## Profiles

Profiles represent an individual user’s fitness tracking profile.

Each profile stores:

- Display name
- Default measurement unit (`in` or `cm`)
- Associated check-ins (coming next)

### CRUD Functionality

The application currently supports full CRUD operations for profiles:

| Action | Route | Description |
|------|------|-------------|
| Index | `/profiles` | View all profiles |
| Show | `/profiles/:id` | View a single profile |
| New | `/profiles/new` | Create a profile |
| Edit | `/profiles/:id/edit` | Edit profile details |
| Delete | `/profiles/:id` | Remove a profile |

### Validations

Profiles enforce the following validations:

- `display_name`
  - required
  - minimum length: 2
  - maximum length: 50

- `default_unit`
  - required
  - must be either `in` or `cm`

---

# Error Handling

The application gracefully handles attempts to access profiles that do not exist.

If a user attempts to access a missing profile, the application:

- rescues `ActiveRecord::RecordNotFound`
- redirects the user to the profile index
- displays a flash message:
