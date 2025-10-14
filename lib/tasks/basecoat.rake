require 'fileutils'

namespace :basecoat do
  desc "Install Basecoat application layout and partials"
  task :install do
    # Install basecoat-css
    puts "\n📦 Installing basecoat-css..."
    if File.exist?(Rails.root.join("package.json"))
      system("yarn add basecoat-css") || system("npm install basecoat-css")
      puts "  Installed: basecoat-css via yarn/npm"
    else
      # Using importmap
      system("bin/rails importmap:install") unless File.exist?(Rails.root.join("config/importmap.rb"))
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

    # Add CSS for view transitions and form validation
    css_path = Rails.root.join("app/assets/stylesheets/application.css")
    if File.exist?(css_path)
      css_content = File.read(css_path)

      unless css_content.include?("view-transition")
        css_code = <<~CSS

          /* View transitions */
          ::view-transition-old(root) {
            animation: 200ms ease-out slide-out-left;
          }
          ::view-transition-new(root) {
            animation: 400ms ease-in slide-in-right;
          }

          @keyframes slide-out-left {
            to { transform: translateX(-30px); opacity: 0; }
          }

          @keyframes slide-in-right {
            from { transform: translateX(30px); opacity: 0; }
          }

          /* Form validation styles */
          label[aria-invalid="true"] {
              color: var(--color-destructive);
          }
        CSS
        File.open(css_path, "a") { |f| f.write(css_code) }
        puts "  Added: View transition styles to app/assets/stylesheets/application.css"
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
      devise_source = File.expand_path("../../generators/basecoat/templates/devise", __dir__)
      devise_destination = Rails.root.join("app/views/devise")

      FileUtils.mkdir_p(devise_destination)
      FileUtils.cp_r("#{devise_source}/.", devise_destination)
      puts "  Created: app/views/devise/"

      # Copy devise layout
      layout_source = File.expand_path("../../generators/basecoat/templates/devise.html.erb", __dir__)
      layout_destination = Rails.root.join("app/views/layouts/devise.html.erb")

      FileUtils.mkdir_p(File.dirname(layout_destination))
      FileUtils.cp(layout_source, layout_destination)
      puts "  Created: app/views/layouts/devise.html.erb"

      puts "\n✓ Basecoat Devise views installed successfully!"
      puts "  Make sure you have Devise configured in your application."
    end

    desc "Install Basecoat Pagy pagination styles"
    task :pagy do
      # Copy pagy styles
      pagy_source = File.expand_path("../generators/basecoat/templates/pagy.scss", __dir__)
      pagy_destination = Rails.root.join("app/assets/stylesheets/pagy.scss")

      FileUtils.mkdir_p(File.dirname(pagy_destination))
      FileUtils.cp(pagy_source, pagy_destination)
      puts "  Created: app/assets/stylesheets/pagy.scss"

      puts "\n✓ Basecoat Pagy styles installed successfully!"
      puts "  Make sure you have Pagy configured in your application."
    end
  end
end
