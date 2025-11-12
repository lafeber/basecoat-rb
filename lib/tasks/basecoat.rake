require 'fileutils'

namespace :basecoat do
  # Helper method to prompt for overwrite confirmation
  def prompt_overwrite(file_path, overwrite_all)
    return true if overwrite_all[:value]
    return true unless File.exist?(file_path)

    print "  Overwrite #{file_path.relative_path_from(Rails.root)}? [y/n/a] "
    response = STDIN.gets.chomp.downcase

    if response == 'a'
      overwrite_all[:value] = true
      true
    elsif response == 'y'
      true
    else
      false
    end
  end

  desc "Install Basecoat application layout and partials"
  task :install do
    no_package_manager = false
    overwrite_all = { value: false }
    # Install basecoat-css (detect package manager)
    puts "\n📦 Installing basecoat-css..."

    # Detect package manager
    if File.exist?(Rails.root.join("bun.lock"))
      system("bun add basecoat-css")
      puts "  Installed: basecoat-css via bun"
    elsif File.exist?(Rails.root.join("yarn.lock"))
      system("yarn add basecoat-css")
      puts "  Installed: basecoat-css via yarn"
    elsif File.exist?(Rails.root.join("package-lock.json"))
      system("npm install basecoat-css")
      puts "  Installed: basecoat-css via npm"
    elsif File.exist?(Rails.root.join("pnpm-lock.yaml"))
      system("pnpm add basecoat-css")
      puts "  Installed: basecoat-css via pnpm"
    else
      no_package_manager = true
      puts "  No package manager detected! We'll insert CDN links into _head.html.erb..."
    end

    # If using importmap, also add to importmap.rb for JS
    if File.exist?(Rails.root.join("config/importmap.rb"))
      importmap_path = Rails.root.join("config/importmap.rb")
      importmap_content = File.read(importmap_path)

      unless importmap_content.include?("basecoat-css")
        File.open(importmap_path, "a") do |f|
          f.puts "\npin \"basecoat-css/all\", to: \"https://cdn.jsdelivr.net/npm/basecoat-css@0.3.3/dist/js/all.js\""
        end
        puts "  Added: basecoat-css to config/importmap.rb"
      end
    end

    # Add JavaScript imports and code
    js_path = Rails.root.join("app/javascript/application.js")
    if File.exist?(js_path)
      js_content = File.read(js_path)

      # Add basecoat-css import
      unless js_content.include?("basecoat-css")
        # Add import after the last import line
        js_content = js_content.sub(/(import\s+.*\n)(?!import)/, "\\1import \"basecoat-css/all\"\n")
        File.write(js_path, js_content)
        puts "  Added: basecoat-css import to app/javascript/application.js"
      end

      # Add cool view transition to application.js
      js_content = File.read(js_path)
      unless js_content.include?("Re-initialize basecoat-css components")
        basecoat_js = <<~JS
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
        File.open(js_path, "a") { |f| f.write(basecoat_js) }
        puts "  Added: cool view transition to app/javascript/application.js"
      end

      # Copy theme_controller.js
      theme_controller_source = File.expand_path("../generators/basecoat/templates/theme_controller.js", __dir__)
      theme_controller_destination = Rails.root.join("app/javascript/controllers/theme_controller.js")

      FileUtils.mkdir_p(File.dirname(theme_controller_destination))
      if prompt_overwrite(theme_controller_destination, overwrite_all)
        FileUtils.cp(theme_controller_source, theme_controller_destination)
        puts "  Created: app/javascript/controllers/theme_controller.js"
      else
        puts "  Skipped: app/javascript/controllers/theme_controller.js"
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
    end
    # Traditional setup with app/assets/stylesheets
    # Check for application.tailwind.css first, then application.css
    css_path = if File.exist?(Rails.root.join("app/assets/stylesheets/application.tailwind.css"))
                 Rails.root.join("app/assets/stylesheets/application.tailwind.css")
               else
                 Rails.root.join("app/assets/stylesheets/application.css")
               end

    if File.exist?(css_path)
      css_content = File.read(css_path)

      css_code = <<~CSS
        dl {
            font-size: var(--text-sm);
            dt {
                font-weight: var(--font-weight-bold);
                margin-top: calc(var(--spacing)*4);
            }
        }

        label:has(+ input:required):after {
            content: " *"
        }

        input:user-invalid, .field_with_errors input {
            border-color: var(--color-destructive);
        }

        label:has(+ input:user-invalid), .field_with_errors label {
            color: var(--color-destructive);
        }
      CSS
      File.open(css_path, "a") { |f| f.write(css_code) }
      puts "  Added: basic styles to #{css_path.relative_path_from(Rails.root)}"
    end

    # Extract <head> from existing application.html.erb BEFORE overwriting it
    layout_destination = Rails.root.join("app/views/layouts/application.html.erb")
    partials_source = File.expand_path("../generators/basecoat/templates/layouts", __dir__)
    partials_destination = Rails.root.join("app/views/layouts")

    FileUtils.mkdir_p(partials_destination)

    if File.exist?(layout_destination)
      content = File.read(layout_destination)
      # Extract everything between <head> and </head>
      if content =~ /(<head>.*?<\/head>)/m
        head_content = $1
        head_destination = partials_destination.join("_head.html.erb")
        if prompt_overwrite(head_destination, overwrite_all)
          File.write(head_destination, head_content + "\n")
          puts "  Created: app/views/layouts/_head.html.erb (extracted from existing application.html.erb)"
        else
          puts "  Skipped: app/views/layouts/_head.html.erb"
        end
      else
        # Fallback: copy the template if no <head> found in existing layout
        head_destination = partials_destination.join("_head.html.erb")
        if prompt_overwrite(head_destination, overwrite_all)
          FileUtils.cp("#{partials_source}/_head.html.erb", head_destination)
          puts "  Created: app/views/layouts/_head.html.erb (from template)"
        else
          puts "  Skipped: app/views/layouts/_head.html.erb"
        end
      end
    else
      # No existing layout, use template
      head_destination = partials_destination.join("_head.html.erb")
      if prompt_overwrite(head_destination, overwrite_all)
        FileUtils.cp("#{partials_source}/_head.html.erb", head_destination)
        puts "  Created: app/views/layouts/_head.html.erb (from template)"
      else
        puts "  Skipped: app/views/layouts/_head.html.erb"
      end
    end

    # Copy application layout
    layout_source = File.expand_path("../generators/basecoat/templates/application.html.erb", __dir__)
    if prompt_overwrite(layout_destination, overwrite_all)
      FileUtils.cp(layout_source, layout_destination)
      puts "  Created: app/views/layouts/application.html.erb"
    else
      puts "  Skipped: app/views/layouts/application.html.erb"
    end

    # Copy layout partials (except _head.html.erb which we already handled)
    Dir.glob("#{partials_source}/*").each do |file|
      filename = File.basename(file)
      next if filename == "_head.html.erb" # Skip _head.html.erb, we already created it
      destination = partials_destination.join(filename)
      if prompt_overwrite(destination, overwrite_all)
        FileUtils.cp(file, destination)
        puts "  Created: app/views/layouts/#{filename}"
      else
        puts "  Skipped: app/views/layouts/#{filename}"
      end
    end

    # Copy shared partials
    shared_source = File.expand_path("../generators/basecoat/templates/shared", __dir__)
    shared_destination = Rails.root.join("app/views/shared")

    FileUtils.mkdir_p(shared_destination)
    Dir.glob("#{shared_source}/*").each do |file|
      filename = File.basename(file)
      destination = shared_destination.join(filename)
      if prompt_overwrite(destination, overwrite_all)
        FileUtils.cp(file, destination)
        puts "  Created: app/views/shared/#{filename}"
      else
        puts "  Skipped: app/views/shared/#{filename}"
      end
    end

    if no_package_manager
      head_path = Rails.root.join("app/views/layouts/_head.html.erb")
      if File.exist?(head_path)
        head_content = File.read(head_path)
        unless head_content.include?("basecoat.cdn.min.css")
          cdn_link = '  <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/basecoat-css@0.3.3/dist/basecoat.cdn.min.css">'
          # Insert before the closing </head> tag
          updated_content = head_content.sub(/(<\/head>)/, "#{cdn_link}\n\\1")
          File.write(head_path, updated_content)
          puts "  Added: CDN link to app/views/layouts/_head.html.erb"
        end
      end
    end

    # Copy scaffold hook initializer
    initializer_source = File.expand_path("../generators/basecoat/templates/scaffold_hook.rb", __dir__)
    initializer_destination = Rails.root.join("config/initializers/scaffold_hook.rb")

    FileUtils.mkdir_p(File.dirname(initializer_destination))
    if prompt_overwrite(initializer_destination, overwrite_all)
      FileUtils.cp(initializer_source, initializer_destination)
      puts "  Created: config/initializers/scaffold_hook.rb"
    else
      puts "  Skipped: config/initializers/scaffold_hook.rb"
    end

    puts "\n✓ Basecoat installed successfully!"
    puts "  Scaffold templates are automatically available from the gem."
    puts "  You can now run: rails generate scaffold YourModel"
  end

  namespace :install do
    desc "Install Basecoat Devise views and layout"
    task :devise do
      overwrite_all = { value: false }

      # Copy devise views
      devise_source = File.expand_path("../generators/basecoat/templates/devise", __dir__)
      devise_destination = Rails.root.join("app/views/devise")

      FileUtils.mkdir_p(devise_destination)
      Dir.glob("#{devise_source}/**/*").each do |file|
        next if File.directory?(file)
        relative_path = Pathname.new(file).relative_path_from(Pathname.new(devise_source))
        destination = devise_destination.join(relative_path)
        FileUtils.mkdir_p(File.dirname(destination))
        if prompt_overwrite(destination, overwrite_all)
          FileUtils.cp(file, destination)
          puts "  Created: app/views/devise/#{relative_path}"
        else
          puts "  Skipped: app/views/devise/#{relative_path}"
        end
      end

      # Copy devise layout
      layout_source = File.expand_path("../generators/basecoat/templates/devise.html.erb", __dir__)
      layout_destination = Rails.root.join("app/views/layouts/devise.html.erb")

      FileUtils.mkdir_p(File.dirname(layout_destination))
      if prompt_overwrite(layout_destination, overwrite_all)
        FileUtils.cp(layout_source, layout_destination)
        puts "  Created: app/views/layouts/devise.html.erb"
      else
        puts "  Skipped: app/views/layouts/devise.html.erb"
      end

      # Add user dropdown to header partial
      header_path = Rails.root.join("app/views/layouts/_header.html.erb")
      if File.exist?(header_path)
        header_content = File.read(header_path)
        unless header_content.include?("dropdown-user")
          user_dropdown = <<~HTML

            <% if defined?(user_signed_in?) && user_signed_in? %>
              <div id="dropdown-user" class="dropdown-menu">
                <button type="button" id="dropdown-user-trigger" aria-haspopup="menu" aria-controls="dropdown-user-menu" aria-expanded="false" class="btn-ghost size-8">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-user-icon lucide-circle-user"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="10" r="3"/><path d="M7 20.662V19a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v1.662"/></svg>
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
          updated_content = header_content.sub("<!-- AUTHENTICATION_DROPDOWN -->", user_dropdown)
          File.write(header_path, updated_content)
          puts "  Added: User dropdown to app/views/layouts/_header.html.erb"
        end
      end

      puts "\n✓ Basecoat Devise views installed successfully!"
      puts "  Make sure you have Devise configured in your application."
    end

    desc "Install Basecoat Pagy pagination styles"
    task :pagy do
      overwrite_all = { value: false }
      pagy_source = File.expand_path("../generators/basecoat/templates/pagy.scss", __dir__)

      # Check if using Tailwind v4 setup (app/assets/tailwind)
      if File.exist?(Rails.root.join("app/assets/tailwind/application.css"))
        # Copy pagy styles to tailwind directory
        pagy_destination = Rails.root.join("app/assets/tailwind/pagy.scss")
        FileUtils.mkdir_p(File.dirname(pagy_destination))
        if prompt_overwrite(pagy_destination, overwrite_all)
          FileUtils.cp(pagy_source, pagy_destination)
          puts "  Created: app/assets/tailwind/pagy.scss"
        else
          puts "  Skipped: app/assets/tailwind/pagy.scss"
        end

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
        if prompt_overwrite(pagy_destination, overwrite_all)
          FileUtils.cp(pagy_source, pagy_destination)
          puts "  Created: app/assets/stylesheets/pagy.scss"
        else
          puts "  Skipped: app/assets/stylesheets/pagy.scss"
        end
      end

      puts "\n✓ Basecoat Pagy styles installed successfully!"
      puts "  Make sure you have Pagy configured in your application."
    end

    desc "Install Basecoat authentication views and layout"
    task :authentication do
      overwrite_all = { value: false }

      # Copy sessions views
      sessions_source = File.expand_path("../generators/basecoat/templates/sessions", __dir__)
      sessions_destination = Rails.root.join("app/views/sessions")

      FileUtils.mkdir_p(sessions_destination)
      Dir.glob("#{sessions_source}/**/*").each do |file|
        next if File.directory?(file)
        relative_path = Pathname.new(file).relative_path_from(Pathname.new(sessions_source))
        destination = sessions_destination.join(relative_path)
        FileUtils.mkdir_p(File.dirname(destination))
        if prompt_overwrite(destination, overwrite_all)
          FileUtils.cp(file, destination)
          puts "  Created: app/views/sessions/#{relative_path}"
        else
          puts "  Skipped: app/views/sessions/#{relative_path}"
        end
      end

      # Copy passwords views
      passwords_source = File.expand_path("../generators/basecoat/templates/passwords", __dir__)
      passwords_destination = Rails.root.join("app/views/passwords")

      FileUtils.mkdir_p(passwords_destination)
      Dir.glob("#{passwords_source}/**/*").each do |file|
        next if File.directory?(file)
        relative_path = Pathname.new(file).relative_path_from(Pathname.new(passwords_source))
        destination = passwords_destination.join(relative_path)
        FileUtils.mkdir_p(File.dirname(destination))
        if prompt_overwrite(destination, overwrite_all)
          FileUtils.cp(file, destination)
          puts "  Created: app/views/passwords/#{relative_path}"
        else
          puts "  Skipped: app/views/passwords/#{relative_path}"
        end
      end

      # Copy sessions layout
      layout_source = File.expand_path("../generators/basecoat/templates/sessions.html.erb", __dir__)
      layout_destination = Rails.root.join("app/views/layouts/sessions.html.erb")

      FileUtils.mkdir_p(File.dirname(layout_destination))
      if prompt_overwrite(layout_destination, overwrite_all)
        FileUtils.cp(layout_source, layout_destination)
        puts "  Created: app/views/layouts/sessions.html.erb"
      else
        puts "  Skipped: app/views/layouts/sessions.html.erb"
      end

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

      # Add user dropdown to header partial
      header_path = Rails.root.join("app/views/layouts/_header.html.erb")
      if File.exist?(header_path)
        header_content = File.read(header_path)
        unless header_content.include?("dropdown-user")
          user_dropdown = <<~HTML

            <% if defined?(Current) && defined?(Current.user) && Current.user %>
              <div id="dropdown-user" class="dropdown-menu">
                <button type="button" id="dropdown-user-trigger" aria-haspopup="menu" aria-controls="dropdown-user-menu" aria-expanded="false" class="btn-ghost size-8">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-circle-user-icon lucide-circle-user"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="10" r="3"/><path d="M7 20.662V19a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v1.662"/></svg>
                </button>
                <div id="dropdown-user-popover" data-popover="" aria-hidden="true" data-align="end">
                  <div role="menu" id="dropdown-user-menu" aria-labelledby="dropdown-user-trigger">
                    <div class="px-1 py-1.5">
                      <%= button_to session_path, method: :delete, class: "btn-link" do %>
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
                        Log out
                      <% end %>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          HTML
          updated_content = header_content.sub("<!-- AUTHENTICATION_DROPDOWN -->", user_dropdown)
          File.write(header_path, updated_content)
          puts "  Added: User dropdown to app/views/layouts/_header.html.erb"
        end
      end

      puts "\n✓ Basecoat authentication views installed successfully!"
      puts "  Make sure you have Rails authentication configured in your application."
    end
  end
end
