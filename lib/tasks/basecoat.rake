require 'fileutils'

namespace :basecoat do
  desc "Install Basecoat scaffold templates"
  task :install do
    source = File.expand_path("../../generators/basecoat/templates/scaffold", __dir__)
    destination = Rails.root.join("lib/templates/erb/scaffold")

    FileUtils.mkdir_p(destination)

    Dir.glob("#{source}/*").each do |file|
      filename = File.basename(file)
      FileUtils.cp(file, destination.join(filename))
      puts "  Created: lib/templates/erb/scaffold/#{filename}"
    end

    puts "\n✓ Basecoat scaffold templates installed successfully!"
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
