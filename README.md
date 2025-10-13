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

**Note:** Basecoat requires Tailwind CSS. If you haven't installed it yet, follow the instructions at [https://github.com/rails/tailwindcss-rails](https://github.com/rails/tailwindcss-rails) to set up Tailwind CSS in your Rails application.

## Usage

### Install Application Layout

Install the Basecoat application layout and partials:

```bash
rake basecoat:install
```

This will:
- Install `basecoat-css` via yarn/npm (if package.json exists) or importmap
- Add basecoat-css import to `app/javascript/application.js`
- Add view transition JavaScript for turbo frames
- Add dark mode toggle functionality
- Add view transition CSS animations and form validation styles
- Copy application layout to `app/views/layouts/application.html.erb`
- Copy layout partials (`_head.html.erb`, `_header.html.erb`, `_aside.html.erb`, `_notice.html.erb`, `_alert.html.erb`, `_form_errors.html.erb`)
- Copy scaffold hook initializer to `config/initializers/scaffold_hook.rb`
- Copy Pagy pagination styles to `app/assets/stylesheets/pagy.scss`

The scaffold templates are automatically available from the gem, so you can immediately generate scaffolds:

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
- ✅ Automatic sidebar navigation links

### Install Devise Views

Install the Basecoat-styled Devise views and layout:

```bash
rake basecoat:install:devise
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

### Application Layout

- **Sidebar Navigation**: Collapsible sidebar with automatic active state detection
- **Header**: User dropdown with sign out functionality
- **Alerts & Notices**: Beautiful toast notifications for flash messages
- **Form Errors**: Consistent error message styling
- **Dark Mode**: Built-in theme toggle

### Scaffold Templates

- **Modern UI**: Clean, professional design using Basecoat CSS
- **Turbo Frames**: SPA-like navigation without full page reloads
- **View Transitions**: Smooth slide animations between pages
- **Smart Forms**: Automatic required field detection based on database schema
- **Auto Sidebar Links**: New scaffolds automatically add navigation links to sidebar
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
- Tailwind CSS ([installation instructions](https://github.com/rails/tailwindcss-rails))
- Basecoat CSS
- Turbo Rails (for scaffold templates)
- Devise (optional, for devise views)

## How It Works

The gem uses Rails' template resolution system to provide scaffold templates automatically. When you run `rails generate scaffold`, Rails will use the templates from the Basecoat gem instead of the default ones.

The application layout and partials are copied to your application so you can customize them as needed.

## Development

After checking out the repo, run `bin/setup` to install dependencies.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
