# Basecoat

Rails scaffold templates and Devise views styled with [Basecoat CSS](https://basecoatui.com).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'basecoat', path: '/Users/martijn.lafeber/sites/basecoat'
```

Or install from a git repository:

```ruby
gem 'basecoat', git: 'https://github.com/yourusername/basecoat'
```

And then execute:

```bash
bundle install
```

## Usage

### Install Scaffold Templates

Install the beautiful Basecoat-styled scaffold templates:

```bash
rake basecoat:install
```

This will copy all scaffold templates to `lib/templates/erb/scaffold/` in your Rails application.

After installation, generate scaffolds as usual:

```bash
rails generate scaffold Post title:string body:text published:boolean
```

The generated views will include:
- ✅ Basecoat CSS styling
- ✅ Turbo Frame support for SPA-like navigation
- ✅ View transitions
- ✅ Responsive design
- ✅ Dark mode support
- ✅ Form validation with required fields
- ✅ Boolean fields styled as switches

### Install Devise Views

Install the Basecoat-styled Devise views and layout:

```bash
rake basecoat:install_devise
```

This will copy:
- All Devise views to `app/views/devise/`
- Devise layout to `app/views/layouts/devise.html.erb`

The Devise views include:
- ✅ Beautiful login/signup forms
- ✅ Two-column layout with image placeholder
- ✅ Dark mode toggle
- ✅ Responsive design
- ✅ Password reset flows
- ✅ Email confirmation views

## Features

### Scaffold Templates

- **Modern UI**: Clean, professional design using Basecoat CSS
- **Turbo Frames**: SPA-like navigation without full page reloads
- **View Transitions**: Smooth slide animations between pages
- **Smart Forms**: Automatic required field detection based on database schema
- **Dark Mode**: Built-in dark mode support
- **Responsive**: Mobile-first responsive design

### Devise Views

- **Professional Design**: Matches modern authentication UI patterns
- **Two-Column Layout**: Image placeholder with form on desktop
- **Complete Views**: All Devise views including confirmations, passwords, registrations
- **Dark Mode**: Toggle between light and dark themes
- **Accessible**: ARIA labels and semantic HTML

## Requirements

- Rails 8.0+
- Basecoat CSS
- Turbo Rails (for scaffold templates)
- Devise (for devise views)

## Development

After checking out the repo, run `bin/setup` to install dependencies.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
