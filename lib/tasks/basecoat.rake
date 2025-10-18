require 'fileutils'

namespace :basecoat do
  desc "Install Basecoat application layout and partials"
  task :install do
    # Install basecoat-css (always install via yarn/npm for CSS)
    puts "\n📦 Installing basecoat-css..."
    system("yarn add basecoat-css") || system("npm install basecoat-css")
    puts "  Installed: basecoat-css via yarn/npm"

    # If using importmap, also add to importmap.rb for JS
    if File.exist?(Rails.root.join("config/importmap.rb"))
      importmap_path = Rails.root.join("config/importmap.rb")
      importmap_content = File.read(importmap_path)
      unless importmap_content.include?("basecoat-css")
        File.open(importmap_path, "a") do |f|
          f.puts "\npin \"basecoat-css/all\", to: \"https://cdn.jsdelivr.net/npm/basecoat-css@0.3.2/dist/js/all.js\""
        end
        puts "  Added: basecoat-css to config/importmap.rb"
      end
    end

    # Add JavaScript imports and code
    js_path = Rails.root.join("app/javascript/application.js")
    if File.exist?(js_path)
      js_content = File.read(js_path)

      unless js_content.include?("basecoat-css")
        # Add import after the last import line
        js_content = js_content.sub(/(import\s+.*\n)(?!import)/, "\\1import \"basecoat-css/all\"\n")
        File.write(js_path, js_content)
        puts "  Added: basecoat-css import to app/javascript/application.js"
      end

      # Add view transitions code
      unless js_content.include?("turbo:before-frame-render")
        view_transition_code = <<~JS

          // View transitions for turbo frame navigation
          addEventListener("turbo:before-frame-render", (event) => {
              if (document.startViewTransition) {
                  const originalRender = event.detail.render
                  event.detail.render = async (currentElement, newElement) => {
                      const transition = document.startViewTransition(() => originalRender(currentElement, newElement))
                      await transition.finished
                  }
              }
          })
        JS
        File.open(js_path, "a") { |f| f.write(view_transition_code) }
        puts "  Added: View transitions to app/javascript/application.js"
      end

      # Add dark mode toggle code
      unless js_content.include?("basecoat:theme")
        dark_mode_code = <<~JS

          // Dark mode toggle
          const apply = dark => {
              document.documentElement.classList.toggle('dark', dark);
              try { localStorage.setItem('themeMode', dark ? 'dark' : 'light'); } catch (_) {}
          };

          // Apply theme on initial load (runs immediately to prevent flash)
          try {
              const stored = localStorage.getItem('themeMode');
              if (stored ? stored === 'dark'
                  : matchMedia('(prefers-color-scheme: dark)').matches) {
                  document.documentElement.classList.add('dark');
              }
          } catch (_) {}

          // Set up theme toggle event listener
          document.addEventListener('basecoat:theme', (event) => {
              const mode = event.detail?.mode;
              apply(mode === 'dark' ? true
                  : mode === 'light' ? false
                      : !document.documentElement.classList.contains('dark'));
          })
        JS
        File.open(js_path, "a") { |f| f.write(dark_mode_code) }
        puts "  Added: Dark mode toggle to app/javascript/application.js"
      end
    end

    # Add CSS imports and styles
    # Check for Tailwind v4 setup first
    if File.exist?(Rails.root.join("app/assets/tailwind/application.css"))
      tailwind_css = Rails.root.join("app/assets/tailwind/application.css")
      content = File.read(tailwind_css)

      # Add basecoat-css import if not present
      unless content.include?("basecoat-css")
        # Add after tailwindcss import
        updated_content = content.sub(/(@import "tailwindcss";)/, "\\1\n@import \"basecoat-css\";")
        File.write(tailwind_css, updated_content)
        puts "  Added: basecoat-css import to app/assets/tailwind/application.css"
      end
    else
      # Traditional setup with app/assets/stylesheets
      css_path = Rails.root.join("app/assets/stylesheets/application.css")
      if File.exist?(css_path)
        css_content = File.read(css_path)

        css_code = <<~CSS
          .field_with_errors label {
              color: var(--color-destructive);
          }
          
          .field_with_errors input {
              border-color: var(--color-destructive);
          }
        CSS
        File.open(css_path, "a") { |f| f.write(css_code) }
        puts "  Added: invalid input styles to app/assets/stylesheets/application.css"
      end
    end

    # Copy application layout
    layout_source = File.expand_path("../generators/basecoat/templates/application.html.erb", __dir__)
    layout_destination = Rails.root.join("app/views/layouts/application.html.erb")

    FileUtils.mkdir_p(File.dirname(layout_destination))
    FileUtils.cp(layout_source, layout_destination)
    puts "  Created: app/views/layouts/application.html.erb"

    # Copy layout partials
    partials_source = File.expand_path("../generators/basecoat/templates/layouts", __dir__)
    partials_destination = Rails.root.join("app/views/layouts")

    Dir.glob("#{partials_source}/*").each do |file|
      filename = File.basename(file)
      FileUtils.cp(file, partials_destination.join(filename))
      puts "  Created: app/views/layouts/#{filename}"
    end

    # Copy scaffold hook initializer
    initializer_source = File.expand_path("../generators/basecoat/templates/scaffold_hook.rb", __dir__)
    initializer_destination = Rails.root.join("config/initializers/scaffold_hook.rb")

    FileUtils.mkdir_p(File.dirname(initializer_destination))
    FileUtils.cp(initializer_source, initializer_destination)
    puts "  Created: config/initializers/scaffold_hook.rb"

    puts "\n✓ Basecoat installed successfully!"
    puts "  Scaffold templates are automatically available from the gem."
    puts "  You can now run: rails generate scaffold YourModel"
  end

  namespace :install do
    desc "Install Basecoat Devise views and layout"
    task :devise do
      # Copy devise views
      devise_source = File.expand_path("../generators/basecoat/templates/devise", __dir__)
      devise_destination = Rails.root.join("app/views/devise")

      FileUtils.mkdir_p(devise_destination)
      FileUtils.cp_r("#{devise_source}/.", devise_destination)
      puts "  Created: app/views/devise/"

      # Copy devise layout
      layout_source = File.expand_path("../generators/basecoat/templates/devise.html.erb", __dir__)
      layout_destination = Rails.root.join("app/views/layouts/devise.html.erb")

      FileUtils.mkdir_p(File.dirname(layout_destination))
      FileUtils.cp(layout_source, layout_destination)
      puts "  Created: app/views/layouts/devise.html.erb"

      # Add user dropdown to header partial
      header_path = Rails.root.join("app/views/layouts/_header.html.erb")
      if File.exist?(header_path)
        header_content = File.read(header_path)
        unless header_content.include?("dropdown-user")
          user_dropdown = <<~HTML

                <% if defined?(user_signed_in?) && user_signed_in? %>
                  <div id="dropdown-user" class="dropdown-menu">
                    <button type="button" id="dropdown-user-trigger" aria-haspopup="menu" aria-controls="dropdown-user-menu" aria-expanded="false" class="btn-icon-ghost rounded-full size-8">
                      <img alt="<%= current_user.email %>" src="https://github.com/lafeber.png" class="size-8 shrink-0 rounded-full">
                    </button>
                    <div id="dropdown-user-popover" data-popover="" aria-hidden="true" data-align="end">
                      <div role="menu" id="dropdown-user-menu" aria-labelledby="dropdown-user-trigger">
                        <div class="px-1 py-1.5">
                          <%= button_to destroy_user_session_path, method: :delete, class: "btn-link" do %>
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
                            Log out
                          <% end %>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
          HTML
          updated_content = header_content.sub("<!-- DEVISE_USER_DROPDOWN -->", user_dropdown)
          File.write(header_path, updated_content)
          puts "  Added: User dropdown to app/views/layouts/_header.html.erb"
        end
      end

      puts "\n✓ Basecoat Devise views installed successfully!"
      puts "  Make sure you have Devise configured in your application."
    end

    desc "Install Basecoat Pagy pagination styles"
    task :pagy do
      pagy_source = File.expand_path("../generators/basecoat/templates/pagy.scss", __dir__)

      # Check if using Tailwind v4 setup (app/assets/tailwind)
      if File.exist?(Rails.root.join("app/assets/tailwind/application.css"))
        # Copy pagy styles to tailwind directory
        pagy_destination = Rails.root.join("app/assets/tailwind/pagy.scss")
        FileUtils.mkdir_p(File.dirname(pagy_destination))
        FileUtils.cp(pagy_source, pagy_destination)
        puts "  Created: app/assets/tailwind/pagy.scss"

        # Add import to tailwind application.css
        tailwind_css = Rails.root.join("app/assets/tailwind/application.css")
        content = File.read(tailwind_css)
        unless content.include?("pagy")
          File.open(tailwind_css, "a") do |f|
            f.puts '@import "./pagy.scss";'
          end
          puts "  Added import to: app/assets/tailwind/application.css"
        end
      else
        # Copy pagy styles to stylesheets directory
        pagy_destination = Rails.root.join("app/assets/stylesheets/pagy.scss")
        FileUtils.mkdir_p(File.dirname(pagy_destination))
        FileUtils.cp(pagy_source, pagy_destination)
        puts "  Created: app/assets/stylesheets/pagy.scss"
      end

      puts "\n✓ Basecoat Pagy styles installed successfully!"
      puts "  Make sure you have Pagy configured in your application."
    end

    desc "Install Basecoat authentication views and layout"
    task :authentication do
      # Copy sessions views
      sessions_source = File.expand_path("../generators/basecoat/templates/sessions", __dir__)
      sessions_destination = Rails.root.join("app/views/sessions")

      FileUtils.mkdir_p(sessions_destination)
      FileUtils.cp_r("#{sessions_source}/.", sessions_destination)
      puts "  Created: app/views/sessions/"

      # Copy passwords views
      passwords_source = File.expand_path("../generators/basecoat/templates/passwords", __dir__)
      passwords_destination = Rails.root.join("app/views/passwords")

      FileUtils.mkdir_p(passwords_destination)
      FileUtils.cp_r("#{passwords_source}/.", passwords_destination)
      puts "  Created: app/views/passwords/"

      # Copy sessions layout
      layout_source = File.expand_path("../generators/basecoat/templates/sessions.html.erb", __dir__)
      layout_destination = Rails.root.join("app/views/layouts/sessions.html.erb")

      FileUtils.mkdir_p(File.dirname(layout_destination))
      FileUtils.cp(layout_source, layout_destination)
      puts "  Created: app/views/layouts/sessions.html.erb"

      # Add layout to passwords_controller
      passwords_controller = Rails.root.join("app/controllers/passwords_controller.rb")
      if File.exist?(passwords_controller)
        content = File.read(passwords_controller)
        unless content.include?('layout "sessions"')
          # Add after the class declaration
          updated_content = content.sub(/(class PasswordsController < ApplicationController\n)/, "\\1  layout \"sessions\"\n\n")
          File.write(passwords_controller, updated_content)
          puts "  Added layout to: app/controllers/passwords_controller.rb"
        end
      end

      puts "\n✓ Basecoat authentication views installed successfully!"
      puts "  Make sure you have Rails authentication configured in your application."
    end
  end
end
