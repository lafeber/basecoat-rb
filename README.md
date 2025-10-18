# All of the shadcn/ui styling, all of the Rails power, no React

This gem provides you with amazing frontend based on [Basecoat CSS](https://basecoatui.com). 
It is especially powerful for admin applications with a lot of CRUD actions. 

Experience beautiful Rails scaffolds, pages for authentication and Devise, and pagy styling. 
All responsive, all dark & light mode. See all the features below.

## Why?

There is a new default component library for the web; it's called shadcn. 
As a developer you are standing on the shoulders of a giant with every component they provide. 
However... in many (most?) applications you don't need complicated components - 
e.g. an input field can just be a html tag, not a separate component with its own shadow DOM. 

This is where basecoat-css comes in.

You can still include complicated shadcn React components if you need them, 
but most of your application is just the simple rails views, leveraging the power of Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'basecoat'
```

And then execute:

```bash
bundle install
```

**Note:** Basecoat requires Tailwind CSS. If you haven't installed it yet, follow the instructions at [https://github.com/rails/tailwindcss-rails](https://github.com/rails/tailwindcss-rails) to set up Tailwind CSS in your Rails application.

## Usage

Run the rake tasks, run a scaffold and observe beauty.

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

The scaffold templates are automatically available from the gem, so you can immediately generate scaffolds:

```bash
rails generate scaffold Post title:string body:text published:boolean
```

The generated views will include:
*  Basecoat CSS styling
*  Turbo Frame support for SPA-like navigation
*  View transitions
*  Responsive design
*  Dark mode support
*  Form validation with required fields
*  Boolean fields styled as switches
*  Automatic sidebar navigation links

### Install Devise Views

Install the Basecoat-styled Devise views and layout:

```bash
rake basecoat:install:devise
```

This will copy:
- All Devise views to `app/views/devise/`
- Devise layout to `app/views/layouts/devise.html.erb`

The Devise views include:
-  Beautiful login/signup forms
*  Two-column layout with image placeholder
*  Dark mode toggle
*  Responsive design
*  Password reset flows
*  Email confirmation views

### Install Pagy Pagination Styles

Install the Basecoat-styled Pagy pagination:

```bash
rake basecoat:install:pagy
```

This will copy:
- Pagy styles to `app/assets/stylesheets/pagy.scss`

The Pagy styles include:

*  Basecoat CSS button styling using `@apply`
*  Proper spacing and layout
*  Active page highlighting
*  Disabled state styling

### Install Authentication Views

Install the Basecoat-styled authentication views (for Rails built-in authentication):

```bash
rake basecoat:install:authentication
```

This will copy:
- Sessions views to `app/views/sessions/`
- Passwords views to `app/views/passwords/`
- Sessions layout to `app/views/layouts/sessions.html.erb`
- Adds `layout "sessions"` to `app/controllers/passwords_controller.rb`

The authentication views include:

*  Beautiful sign in form
*  Password reset flows
*  Two-column layout with image placeholder
*  Dark mode toggle
*  Responsive design
*  Consistent styling with Devise views

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

## How It Works

The gem uses Rails' template resolution system to provide scaffold templates automatically. When you run `rails generate scaffold`, Rails will use the templates from the Basecoat gem instead of the default ones.

The application layout and partials are copied to your application so you can customize them as needed.

## Discussion

I tried not to be too opinionated with my scaffolds - they're very close to the original ones. With the exception of 
using a turbo frame main_content. I love this too much not to include it.

However, I have my doubts with the index page reusing the show partial. Especially in admin applications you might want 
to have a (responsive) table in the index.

Also, the arguably ugliest part of the views are the svg tags which contains the lovely lucide icons. 
Since these icons are the default for shadcn I'm considering including https://github.com/heyvito/lucide-rails to clean up the views. 

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
