require 'fileutils'

namespace :basecoat do
  desc "Install Basecoat application layout and partials"
  task :install do
    # Copy application layout
    layout_source = File.expand_path("../../generators/basecoat/templates/application.html.erb", __dir__)
    layout_destination = Rails.root.join("app/views/layouts/application.html.erb")

    FileUtils.mkdir_p(File.dirname(layout_destination))
    FileUtils.cp(layout_source, layout_destination)
    puts "  Created: app/views/layouts/application.html.erb"

    # Copy layout partials
    partials_source = File.expand_path("../../generators/basecoat/templates/layouts", __dir__)
    partials_destination = Rails.root.join("app/views/layouts")

    Dir.glob("#{partials_source}/*").each do |file|
      filename = File.basename(file)
      FileUtils.cp(file, partials_destination.join(filename))
      puts "  Created: app/views/layouts/#{filename}"
    end

    # Copy scaffold hook initializer
    initializer_source = File.expand_path("../../generators/basecoat/templates/scaffold_hook.rb", __dir__)
    initializer_destination = Rails.root.join("config/initializers/scaffold_hook.rb")

    FileUtils.mkdir_p(File.dirname(initializer_destination))
    FileUtils.cp(initializer_source, initializer_destination)
    puts "  Created: config/initializers/scaffold_hook.rb"

    puts "\n✓ Basecoat installed successfully!"
    puts "  Scaffold templates are automatically available from the gem."
    puts "  You can now run: rails generate scaffold YourModel"
  end

  desc "Install Basecoat Devise views and layout"
  task :install_devise do
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
end
