# Basecoat powered views for Rails

This gem provides you with amazing layouts, scaffolds, views and partials based on [Basecoat UI](https://basecoatui.com).
It is especially powerful for admin applications with a lot of CRUD actions.

Beautiful responsive, dark & light mode Rails scaffolds, pages for authentication and Devise, and pagy styling.

## Why?

Shadcn has quickly the default ui for the web. However, we don't need /really/ the all the React components.

This is where basecoat-ui comes in. The reason why I chose basecoat is because it combines tailwind with clean css classes (like daisy-ui). 

You can combine it with https://railsblocks.com/ or 

## Installation

Add this line to your application's Gemfile in the development group:

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

The generated views will include:
*  Basecoat CSS styling
*  Turbo Frame support for SPA-like navigation
*  View transitions
*  Responsive design
*  Dark mode support
*  Form validation with required fields
*  Boolean fields styled as switches
*  Automatic sidebar navigation links

The scaffold templates are automatically available from the gem, so you can immediately generate scaffolds:

```bash
rails generate scaffold Post title:string body:text published:boolean
```

### Install Devise Views

Install the Basecoat-styled Devise views and layout:

```bash
rake basecoat:install:devise
```

### Install Authentication Views

Install the Basecoat-styled authentication views (for Rails built-in authentication):

```bash
rake basecoat:install:authentication
```

### Install Pagy Pagination Styles

Install the Basecoat-styled Pagy pagination:

```bash
rake basecoat:install:pagy
```

## Requirements

- Rails 8.0+
- Tailwind CSS ([installation instructions](https://github.com/rails/tailwindcss-rails))
- Basecoat CSS
- Turbo Rails (for scaffold templates)
- Stimulus (for the theme toggle, can be moved to something else if you desire...)

## Discussion

I tried not to be too opinionated with my scaffolds - they're very close to the original ones. With the exception of 
using a turbo frame main_content. I love this too much not to include it.

However, I have my doubts with the index page reusing the show partial. Especially in admin applications you might want 
to have a (responsive) table in the index.

Also, the arguably ugliest part of the views are the svg tags which contains the lovely lucide icons. 
Since these icons are the default for shadcn I'm considering including https://github.com/heyvito/lucide-rails to clean up the views. 

## Issues

* The javascript included by basecoat needs some improvement. It's not automatically initialized on turbo:load
* We include extra css for the definition list. Hopefully this will be part of basecoat-css someday.
* Rails adds class="field_with_errors", so we need extra css for this. I hope Rails will at some point have aria-invalid="true" on the input, which will automatically include the correct styling.
* Can the views even be prettier? Probably! I'm more than happy to discuss improvements:

## Contributing

Bug reports and pull requests are more than welcome on GitHub!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
